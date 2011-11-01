package org.svnadmin.service;

import java.io.File;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.lang.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.svnadmin.Constants;
import org.svnadmin.dao.PjAuthDao;
import org.svnadmin.dao.PjDao;
import org.svnadmin.dao.PjGrDao;
import org.svnadmin.dao.PjGrUsrDao;
import org.svnadmin.dao.PjUsrDao;
import org.svnadmin.entity.Pj;
import org.svnadmin.entity.PjGr;
import org.svnadmin.util.I18N;
import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;

/**
 * 项目服务层
 * 
 * @author <a href="mailto:yuanhuiwu@gmail.com">Huiwu Yuan</a>
 * @since 1.0
 * 
 */
@Service(PjService.BEAN_NAME)
public class PjService {
	/**
	 * Bean名称
	 */
	public static final String BEAN_NAME = "pjService";

	/**
	 * 项目DAO
	 */
	@Resource(name = PjDao.BEAN_NAME)
	protected PjDao pjDao;

	/**
	 * 项目用户DAO
	 */
	@Resource(name = PjUsrDao.BEAN_NAME)
	protected PjUsrDao pjUsrDao;

	/**
	 * 项目组DAO
	 */
	@Resource(name = PjGrDao.BEAN_NAME)
	protected PjGrDao pjGrDao;

	/**
	 * 项目组用户DAO
	 */
	@Resource(name = PjGrUsrDao.BEAN_NAME)
	protected PjGrUsrDao pjGrUsrDao;

	/**
	 * 项目权限DAO
	 */
	@Resource(name = PjAuthDao.BEAN_NAME)
	protected PjAuthDao pjAuthDao;

	/**
	 * SVN服务层
	 */
	@Resource(name = SvnService.BEAN_NAME)
	protected SvnService svnService;

	/**
	 * @param pj
	 *            项目
	 * @return 项目
	 */
	public Pj get(String pj) {
		return pjDao.get(pj);
	}

	/**
	 * @return 项目列表
	 */
	public List<Pj> list() {
		return pjDao.getList();
	}

	/**
	 * @param usr
	 *            用户
	 * @return 用户有权限的项目列表(用户是否是这个项目的管理员)
	 */
	public List<Pj> list(String usr) {
		return pjDao.getList(usr);
	}

	/**
	 * 删除(同时删除项目权限，项目组用户，项目组，项目用户)
	 * 
	 * @param pj
	 *            项目
	 */
	@Transactional
	public void delete(String pj) {
		pjAuthDao.deletePj(pj);
		pjGrUsrDao.deletePj(pj);
		pjGrDao.deletePj(pj);
		pjUsrDao.deletePj(pj);

		svnService.exportConfig(pj);

		pjDao.delete(pj);
	}

	/**
	 * 保存。<br>
	 * 数据库里已经存在相同的路径或url的项目，不可以保存。<br>
	 * 如果仓库不存在，自动创建。<br>
	 * 如果是增加项目，自动创建默认3个组。
	 * 
	 * @param pj
	 *            项目
	 */
	@Transactional
	public void save(Pj pj) {
		// 路径 把\替换为/，转为小写
		if (StringUtils.isNotBlank(pj.getPath())) {
			pj.setPath(StringUtils.replace(pj.getPath(), "\\", "/")
					.toLowerCase());// 小写
		}
		// url 把\替换为/，转为小写
		if (StringUtils.isNotBlank(pj.getUrl())) {
			pj.setUrl(StringUtils.replace(pj.getUrl(), "\\", "/").toLowerCase());// 小写
		}

		// 是否可以增加项目
		boolean insert = pjDao.get(pj.getPj()) == null;
		if (insert) {
			// 数据库里已经存在相同的路径或url的项目
			if (this.pjDao.getCount(pj.getPath(), pj.getUrl()) > 0) {
				throw new RuntimeException(I18N.getLbl("pj.save.error.existPathOrUrl", "数据库里已经存在相同的路径或url的仓库项目，请检查路径或url"));
			}
		} else {
			// 数据库里已经存在相同的路径或url的项目
			if (this.pjDao.getCount(pj.getPath(), pj.getUrl()) > 1) {
				throw new RuntimeException(I18N.getLbl("pj.save.error.existMutilPathOrUrl","数据库里已经存在多个相同的路径或url的仓库项目，请检查路径或url"));
			}
		}
		// 创建仓库
		File respository = new File(pj.getPath());
		if (!respository.exists() || !respository.isDirectory()) {// 不存在仓库
			try {
				SVNRepositoryFactory.createLocalRepository(respository, true,
						false);
			} catch (SVNException e) {
				throw new RuntimeException(I18N.getLbl("pj.save.error.createRepository","创建仓库失败.{0}",new Object[]{pj.getPath()}) 
				+ " : "+ e.getMessage());
			}
		}
		// 增加默认的组
		if (insert) {
			this.pjDao.insert(pj);
			for (String gr : Constants.GROUPS) {
				PjGr pjGr = new PjGr();
				pjGr.setPj(pj.getPj());
				pjGr.setGr(gr);
				pjGr.setDes(gr);
				pjGrDao.save(pjGr);
			}
		} else {
			this.pjDao.update(pj);
		}
		svnService.exportConfig(pj.getPj());
	}
}

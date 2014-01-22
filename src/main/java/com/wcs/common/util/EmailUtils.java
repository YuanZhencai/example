/** * EmailUtils.java 
 * Created on 2014年1月22日 上午10:56:57 
 */

package com.wcs.common.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.wcs.common.util.vo.A1;
import com.wcs.common.util.vo.SubVo;

/** 
* <p>Project: example</p> 
* <p>Title: EmailUtils.java</p> 
* <p>Description: </p> 
* <p>Copyright (c) 2014 Wilmar Consultancy Services</p>
* <p>All Rights Reserved.</p>
* @author <a href="mailto:yuanzhencai@wcs-global.com">Yuan</a> 
*/
public final class EmailUtils {

	private EmailUtils() {
	}

	public static Map<String, List<SubVo>> convertDatas(List<? extends SubVo> datas) {
		List<String> distinctParent = new ArrayList<String>();
		Map<String, List<SubVo>> results = new HashMap<String, List<SubVo>>();
		for (SubVo subVo : datas) {
			String parent = subVo.getParent();
			if (!distinctParent.contains(parent)) {
				results.put(parent, new ArrayList<SubVo>());
				distinctParent.add(parent);
			}
			results.get(parent).add(subVo);
		}
		return results;
	}

	public static void main(String[] args) {
		List<A1> a1s = new ArrayList<A1>();
		for (int i = 0; i < 100; i++) {
			A1 a1 = new A1();
			a1.setId(Long.valueOf(i));
			a1.setFatherCode((Long.valueOf(i / 10)).toString());
			a1.setContent("[content]" + i);
			a1s.add(a1);
		}

		for (A1 a1 : a1s) {
			System.out.println("[value]" + a1.getId() + " " + a1.getFatherCode() + " " + a1.getContent());
		}

		Map<String, List<SubVo>> datas = EmailUtils.convertDatas(a1s);
		for (String key : datas.keySet()) {
			System.out.println("[key]" + key);
			List<SubVo> list = datas.get(key);
			for (int i = 0; i < list.size(); i++) {
				A1 a = (A1) list.get(i);
				System.out.println("[value]" + a.getId() + " " + a.getFatherCode() + " " + a.getContent());
			}
		}
	}

}

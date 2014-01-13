var intervalID;

setInerval();

function setInerval() {
	var intId = sessionStorage.getItem('intervalID');
	console.info("intId:" + intId);
	if (intId != null) {
		interval();
	}
}

function interval() {
	console.info("IntervalID:" + intervalID);
	intervalID = window.clearInterval(intervalID);
	intervalID = window.setInterval(callBackExportStatus, 1000);
	return intervalID;
}

function exportZip() {
	var xmlhttp;
	if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp = new XMLHttpRequest();
	} else {// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.open("POST", "/example/SmartExportServlet", true);
	xmlhttp.send();
	var intId = interval();
	sessionStorage.setItem('intervalID', intId);
}

function isComplete() {
	complete();
}

/**
 * @returns {___anonymous359_365}
 */
function GetXmlHttpObject() {
	var xmlHttp = null;
	try {
		// Firefox, Opera 8.0+, Safari
		xmlHttp = new XMLHttpRequest();
	} catch (e) {
		// Internet Explorer
		try {
			xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
	return xmlHttp;
}

function callBackExportStatus() {
	try {
		var xmlHttp = GetXmlHttpObject();
		if (xmlHttp != null) {
			// 构造查询连接字符串
			var url = "/example/SmartExportServlet";
			// 打开连接
			xmlHttp.open("GET", url, true);
			// 设置回调函数
			xmlHttp.onreadystatechange = function() {
				try {
					if (xmlHttp.readyState == 4) {
						var status = xmlHttp.responseText;
						console.info("status: " + status);
						if ("1" == status) {
							// exportNociceVar.show();
							complete();
							console.info("Resopne Complete : " + status);
							window.clearInterval(intervalID);
							sessionStorage.clear();
						}
					}
				} catch (e) {
					console.info("回调处理错误:" + e);
				}
			};
			// 发送请求
			xmlHttp.send(null);
		} else {
			console.info("XMLHTTP对象创建失败");
		}
	} catch (e) {
		console.info("查询错误:" + e);
	}
}

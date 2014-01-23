//全局intervalID
var intervalID;

// 只要刷新页面就要执行
setInerval();

// 判断是否要周期执行
function setInerval() {
	var intId = sessionStorage.getItem('intervalID');
	if (intId != null) {
		interval();
	}
}

// 周期执行
function interval() {
	intervalID = window.clearInterval(intervalID);
	intervalID = window.setInterval(getExportStatus, 1000);
	sessionStorage.setItem('intervalID', intervalID);
}

function getExportStatus() {
	exportStatus();
}

function stopInterval(xhr, status, args) {
	console.info("stopInterval");
	if (args.status == "1") {
		window.clearInterval(intervalID);
		sessionStorage.clear();
		exportNociceVar.show();
		console.info("success");
	}
}
// 精灵导出
function exportSmarts() {
	var xmlhttp;
	if (window.XMLHttpRequest) {
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp = new XMLHttpRequest();
	} else {
		// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	// 发送导出请求
	var contextPath = $("#requestContextPath").val();
	var url = contextPath + "/SmartExportServlet";
	xmlhttp.open("POST", url, true);
	xmlhttp.send();
	// 周期执行
	interval();
}

// xmlhttp
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

// 导出结果
function callBackExportStatus() {
	try {
		var xmlHttp = GetXmlHttpObject();
		if (xmlHttp != null) {
			// 取得导出结果
			var contextPath = $("#requestContextPath").val();
			var url = contextPath + "/SmartExportServlet";
			xmlHttp.open("GET", url, true);
			xmlHttp.onreadystatechange = function() {
				try {
					if (xmlHttp.readyState == 4) {
						var status = xmlHttp.responseText;
						if ("1" == status || "0" == status) {
							// complete();
							exportNociceVar.show();
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

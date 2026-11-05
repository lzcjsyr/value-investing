BEGIN;

INSERT INTO vi_metric_base (id, code, name, unit, category, source_name, frequency, valid_min, valid_max, notes, company_id, basis, measure) VALUES
(2, 'CGB10Y.CCDC', '中债国债10年到期收益率', '%', '利率', '中国债券信息网（中央结算公司），自动采集', '工作日', 0, 20, '单位为百分数：1.65 表示 1.65%。与中证口径分开存放，不拼接。', NULL, '时点', '时点'),
(3, 'CGB10Y.CSI', '10年国债到期收益率（中证口径）', '%', '利率', 'Wind M1001654（中证指数公司），2026-08/09 手工备份', '工作日', 0, 20, '旧本地 Wind 采集，已停更；与中债口径不同，仅作历史对照。', NULL, '时点', '时点'),
(9, 'SP.SHFE.WIND', '纸浆期货收盘价（Wind 活跃合约）', '元/吨', '商品', 'Wind EDB M0330982（上海期货交易所），2026-10-22 一次性备份 2021-10 至今', '交易日', 2000, 12000, '上期所纸浆期货的交割品是漂白针叶浆，只代表针叶浆价格方向；太阳纸业外购浆以阔叶浆为主、自制浆六成以上。看利润要看“纸价−浆价”的价差，不能只看浆价。Wind 积分不足时不再更新，之后用新浪口径。', NULL, '时点', '时点'),
(10, 'SP.SHFE.SINA', '纸浆期货最新价（新浪 SP0 连续）', '元/吨', '商品', '新浪期货行情，自动采集（每天 18:30 或按按钮）', '交易日', 2000, 12000, '与 Wind“活跃合约收盘价”口径不同（连续合约、最新价），分开存放、不拼接。晚上 21 点后夜盘时段采集到的是夜盘最新价。', NULL, '时点', '时点'),
(29, 'HKDCNY', '港元兑人民币', '人民币/港元', '汇率', '腾讯外汇行情 whHKDCNY（自动采集）；近一年日线由腾讯 K 线接口补齐', '交易日', 0.7, 1.1, '1 港元折合多少人民币。用于把港股股价折成人民币，与人民币记账的估值比较。', NULL, '时点', '时点'),
(320, 'OP.SHFE.SINA', '胶版印刷纸期货（新浪 OP0 连续）', '元/吨', '商品', '新浪期货 OP0 连续（采集工作流）；历史为跟踪脚本补的日收盘价（akshare futures_main_sina）', '交易日', 1000, 20000, '上期所胶版印刷纸期货（2025-09-10 上市），交割品为双胶纸（胶版印刷纸），是文化纸价格的公开日度参照；看“纸价 − 浆价”的价差，不只看纸价。', NULL, '时点', '时点');

INSERT INTO vi_collector_base (id, name, url, parser, parser_param, enabled, max_lag_days, last_selfcheck, selfcheck_result, notes, metric_id) VALUES
(2, '中债国债10年收益率', 'https://yield.chinabond.com.cn/cbweb-pbc-web/pbc/more?locale=cn_zh', 'chinabond_curve', '10年', TRUE, 7, '2026-10-23T12:58:37.399579+08:00', '正常；未通知', '按表头“10年”所在列取“中债国债收益率曲线”一行。', 2),
(5, '纸浆期货（新浪 SP0）', 'https://hq.sinajs.cn/list=nf_SP0', 'sina_future', 'SP0', TRUE, 7, '2026-10-23T12:58:37.399579+08:00', '正常；未通知', '新浪接口必须带 Referer 请求头（采集工作流已统一加上），否则返回 403。第 9 段为最新价、第 18 段为日期。', 10),
(10, '港元兑人民币（腾讯外汇）', 'https://qt.gtimg.cn/q=whHKDCNY', 'tencent_fx', 'whHKDCNY', TRUE, 7, '2026-10-23T12:58:37.399579+08:00', '正常；未通知', '市场汇率（非中间价）；第 6 段是时间戳 YYYYMMDDhhmmss。', 29),
(12, '胶版印刷纸期货（新浪 OP0）', 'https://hq.sinajs.cn/list=nf_OP0', 'sina_future', 'OP0', TRUE, 7, NULL, NULL, '与纸浆期货同一新浪接口（必须带 Referer）；第 9 段为最新价、第 18 段为日期。按钮在 21:00 以后点，抓到的是夜盘最新价。', 320);

INSERT INTO vi_raw_capture_base (id, run_label, collected_at, status, raw_response, collector_id, fetch_result, run_id) VALUES
(2, 'CHINABOND-CGB10Y|2026/09/19 21:46', '2026-09-19T21:46:01.467+08:00', '已入库', '{"$endTime":1789825561409,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-18\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-18(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9702 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1802</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1902</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2298</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2659</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4070</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5054</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6820</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1260</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3900 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4279</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4552</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4860</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5529</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5762</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7364</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9213</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.3125</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4750</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4872</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5179</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6390</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7122</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8329</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0194</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Content-Language":"und","Strict-Transport-Security":"max-age=30; includeSubDomains;","Date":"Sat, 19 Sep 2026 13:46:01 GMT","Connection":"keep-alive","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","Vary":"Accept-Encoding","Set-Cookie":"JSESSIONID=A37F338BE655A4012F7EE29B3FB8803B; Path=/cbweb-pbc-web; HttpOnly","X-Xss-Protection":"1; mode=block","X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall"},"status_code":200,"$startTime":1789825560978}', 2, NULL, NULL),
(5, 'CHINABOND-CGB10Y|2026/09/19 21:51', '2026-09-19T21:51:01.141+08:00', '重复未入库', '{"$startTime":1789825864400,"$endTime":1789825865416,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-18\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-18(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9702 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1802</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1902</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2298</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2659</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4070</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5054</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6820</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1260</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3900 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4279</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4552</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4860</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5529</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5762</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7364</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9213</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.3125</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4750</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4872</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5179</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6390</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7122</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8329</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0194</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Expect-Ct":"enforce; max-age=86400","Set-Cookie":"JSESSIONID=1E1982A3DA7502FEB4BAD0CD44266F65; Path=/cbweb-pbc-web; HttpOnly","X-Xss-Protection":"1; mode=block","Content-Type":"text/html;charset=UTF-8","Connection":"keep-alive","Content-Language":"und","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall","Date":"Sat, 19 Sep 2026 13:51:05 GMT","Vary":"Accept-Encoding"},"status_code":200}', 2, NULL, NULL),
(9, 'CHINABOND-CGB10Y|2026/09/20 18:30', '2026-09-20T18:30:06.55+08:00', '已入库', '{"headers":{"X-Content-Type-Options":"nosniff","Strict-Transport-Security":"max-age=30; includeSubDomains;","Connection":"keep-alive","Expect-Ct":"enforce; max-age=86400","X-Frame-Options":"allowall","Date":"Sun, 20 Sep 2026 10:30:10 GMT","Set-Cookie":"JSESSIONID=0ECBA9B24B8DB6362D1737310B08B724; Path=/cbweb-pbc-web; HttpOnly","Content-Language":"und","Vary":"Accept-Encoding","X-Xss-Protection":"1; mode=block","Content-Type":"text/html;charset=UTF-8"},"status_code":200,"$startTime":1789900209022,"$endTime":1789900210404,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-20\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-20(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9402 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1802</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1902</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2298</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2768</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4055</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5054</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6818</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1210</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4279</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4577</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4867</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5565</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5723</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7280</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9129</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.3125</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4669 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4850</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4945</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5165</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6431</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7001</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8245</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0110</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(10, 'CHINABOND-CGB10Y|2026/09/21 18:30', '2026-09-21T18:30:03.999+08:00', '已入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-21\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-21(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9402 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1800</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1902</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2317</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2870</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4072</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5078</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6829</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1185</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4300</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4518</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4831</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5588</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5723</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7154</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9004</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.3125</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4800 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4850</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4950</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5165</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6378</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6979</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8119</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9953</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall","Connection":"keep-alive","Date":"Mon, 21 Sep 2026 10:30:08 GMT","Content-Type":"text/html;charset=UTF-8","Set-Cookie":"JSESSIONID=F1E0CC268927B09582C37F458F84EE30; Path=/cbweb-pbc-web; HttpOnly","X-Xss-Protection":"1; mode=block","Expect-Ct":"enforce; max-age=86400","Strict-Transport-Security":"max-age=30; includeSubDomains;","Vary":"Accept-Encoding","Content-Language":"und"},"status_code":200,"$startTime":1789986607216,"$endTime":1789986608463}', 2, NULL, NULL),
(15, 'CHINABOND-CGB10Y|2026/09/22 18:30', '2026-09-22T18:30:08.618+08:00', '已入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-22\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-22(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9402 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1865</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1952</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2317</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2847</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4053</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5019</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6791</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1110</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4325</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4496</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4831</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5593</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5667</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7001</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8852</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.3125</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.5000 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4828</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4976</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5128</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6300</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6936</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7967</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9791</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"X-Frame-Options":"allowall","Date":"Tue, 22 Sep 2026 10:30:12 GMT","Connection":"keep-alive","Set-Cookie":"JSESSIONID=3C9AC3BA959D720E401D9B23BAB1391E; Path=/cbweb-pbc-web; HttpOnly","X-Content-Type-Options":"nosniff","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","X-Xss-Protection":"1; mode=block","Vary":"Accept-Encoding","Content-Language":"und","Strict-Transport-Security":"max-age=30; includeSubDomains;"},"status_code":200,"$startTime":1790073011662,"$endTime":1790073012318}', 2, NULL, NULL),
(18, 'CHINABOND-CGB10Y|2026/09/23 18:30', '2026-09-23T18:30:07.503+08:00', '已入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-23\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-23(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9202 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1865</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2002</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2347</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2894</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4073</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5046</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1100</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4325</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4528</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4831</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5588</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5653</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6981</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8760</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.3025</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4700 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4800</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4999</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5114</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6301</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6910</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7939</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9704</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"X-Xss-Protection":"1; mode=block","Date":"Wed, 23 Sep 2026 10:30:12 GMT","Set-Cookie":"JSESSIONID=F6FB6AACD5622F3BB09B9CC76D640F4E; Path=/cbweb-pbc-web; HttpOnly","Strict-Transport-Security":"max-age=30; includeSubDomains;","Connection":"keep-alive","X-Content-Type-Options":"nosniff","Vary":"Accept-Encoding","X-Frame-Options":"allowall","Content-Language":"und","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400"},"status_code":200,"$startTime":1790159410946,"$endTime":1790159412337}', 2, NULL, NULL),
(19, 'CHINABOND-CGB10Y|2026/09/24 18:30', '2026-09-24T18:30:02.43+08:00', '已入库', '{"headers":{"Vary":"Accept-Encoding","X-Xss-Protection":"1; mode=block","Set-Cookie":"JSESSIONID=277BD984D644B6F54509BD838F87F851; Path=/cbweb-pbc-web; HttpOnly","Content-Type":"text/html;charset=UTF-8","X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall","Date":"Thu, 24 Sep 2026 10:30:06 GMT","Expect-Ct":"enforce; max-age=86400","Connection":"keep-alive","Strict-Transport-Security":"max-age=30; includeSubDomains;","Content-Language":"und"},"status_code":200,"$startTime":1790245805442,"$endTime":1790245806369,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-24\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-24(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9202 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1810</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2102</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2327</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2893</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4058</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5012</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6738</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0820</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4300</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4561</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4826</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5575</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5589</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6929</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8524</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2925</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4800</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4936</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5118</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6284</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6867</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7885</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9554</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(24, 'CHINABOND-CGB10Y|2026/09/25 18:30', '2026-09-25T18:30:07.891+08:00', '重复未入库', '{"$endTime":1790332211418,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-24\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-24(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9202 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1810</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2102</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2327</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2893</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4058</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5012</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6738</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0820</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4300</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4561</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4826</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5575</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5589</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6929</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8524</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2925</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4800</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4936</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5118</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6284</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6867</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7885</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9554</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Strict-Transport-Security":"max-age=30; includeSubDomains;","Date":"Fri, 25 Sep 2026 10:30:11 GMT","X-Frame-Options":"allowall","Connection":"keep-alive","Vary":"Accept-Encoding","X-Xss-Protection":"1; mode=block","X-Content-Type-Options":"nosniff","Expect-Ct":"enforce; max-age=86400","Set-Cookie":"JSESSIONID=AB84A0516B57EC499971557643BDC14D; Path=/cbweb-pbc-web; HttpOnly","Content-Language":"und","Content-Type":"text/html;charset=UTF-8"},"status_code":200,"$startTime":1790332210762}', 2, NULL, NULL),
(27, 'CHINABOND-CGB10Y|2026/09/26 18:30', '2026-09-26T18:30:06.875+08:00', '重复未入库', '{"headers":{"Content-Type":"text/html;charset=UTF-8","X-Frame-Options":"allowall","Connection":"keep-alive","X-Content-Type-Options":"nosniff","Content-Language":"und","X-Xss-Protection":"1; mode=block","Set-Cookie":"JSESSIONID=950142E32A68CE9AC150BB2FE5BCAB1F; Path=/cbweb-pbc-web; HttpOnly","Date":"Sat, 26 Sep 2026 10:30:10 GMT","Expect-Ct":"enforce; max-age=86400","Strict-Transport-Security":"max-age=30; includeSubDomains;","Vary":"Accept-Encoding"},"status_code":200,"$startTime":1790418609095,"$endTime":1790418610578,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-24\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-24(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9202 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1810</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2102</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2327</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2893</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4058</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5012</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6738</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0820</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4300</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4561</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4826</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5575</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5589</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6929</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8524</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2925</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4800</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4936</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5118</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6284</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6867</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7885</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9554</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(29, 'CHINABOND-CGB10Y|2026/09/27 18:30', '2026-09-27T18:30:04.475+08:00', '重复未入库', '{"headers":{"Content-Language":"und","Vary":"Accept-Encoding","Content-Type":"text/html;charset=UTF-8","Date":"Sun, 27 Sep 2026 10:30:08 GMT","Connection":"keep-alive","X-Content-Type-Options":"nosniff","Set-Cookie":"JSESSIONID=429378FDEB01BBA209BDE06B8F7E8164; Path=/cbweb-pbc-web; HttpOnly","Expect-Ct":"enforce; max-age=86400","X-Xss-Protection":"1; mode=block","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Frame-Options":"allowall"},"status_code":200,"$startTime":1790505007309,"$endTime":1790505008443,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-24\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-24(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9202 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1810</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2102</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2327</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2893</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4058</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5012</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6738</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0820</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4300</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4561</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4826</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5575</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5589</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6929</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8524</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2925</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4600 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4800</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4936</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5118</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6284</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6867</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7885</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9554</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(31, 'CHINABOND-CGB10Y|2026/09/28 18:30', '2026-09-28T18:30:02.187+08:00', '已入库', '{"headers":{"Vary":"Accept-Encoding","Content-Type":"text/html;charset=UTF-8","X-Content-Type-Options":"nosniff","Set-Cookie":"JSESSIONID=9BEA482FA1E169FCA9E1C7849AA2EB8B; Path=/cbweb-pbc-web; HttpOnly","X-Xss-Protection":"1; mode=block","Connection":"keep-alive","X-Frame-Options":"allowall","Content-Language":"und","Strict-Transport-Security":"max-age=30; includeSubDomains;","Expect-Ct":"enforce; max-age=86400","Date":"Mon, 28 Sep 2026 10:30:06 GMT"},"status_code":200,"$startTime":1790591405638,"$endTime":1790591407317,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-28\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-28(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9202 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1799</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1952</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2257</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2890</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4102</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5042</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6790</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0970</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4150</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4535</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4784</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5575</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5684</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6998</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8555</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2925</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4561</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4926</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5056</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6285</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6879</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7955</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9552</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(35, 'CHINABOND-CGB10Y|2026/09/29 18:30', '2026-09-29T18:30:06.022+08:00', '已入库', '{"$startTime":1790677809061,"$endTime":1790677810329,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-29\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-29(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1742</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1997</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2826</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3948</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4970</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6670</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0735</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4131</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4445</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4759</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5508</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6854</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8436</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2925</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4443</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4848</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5000</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6228</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6855</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7878</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9511</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Content-Language":"und","Expect-Ct":"enforce; max-age=86400","Vary":"Accept-Encoding","Date":"Tue, 29 Sep 2026 10:30:10 GMT","X-Frame-Options":"allowall","Content-Type":"text/html;charset=UTF-8","X-Xss-Protection":"1; mode=block","Strict-Transport-Security":"max-age=30; includeSubDomains;","Connection":"keep-alive","X-Content-Type-Options":"nosniff","Set-Cookie":"JSESSIONID=0CD7447A0CF841BA4E9EBB892904D4F6; Path=/cbweb-pbc-web; HttpOnly"},"status_code":200}', 2, NULL, NULL),
(39, 'CHINABOND-CGB10Y|2026/09/30 18:30', '2026-09-30T18:30:08.264+08:00', '已入库', '{"$startTime":1790764210503,"$endTime":1790764211584,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Content-Type":"text/html;charset=UTF-8","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Content-Type-Options":"nosniff","Date":"Wed, 30 Sep 2026 10:30:11 GMT","Connection":"keep-alive","Vary":"Accept-Encoding","Expect-Ct":"enforce; max-age=86400","Set-Cookie":"JSESSIONID=E3EB3B0C5DB576C9D5FE88AB2791B131; Path=/cbweb-pbc-web; HttpOnly","X-Xss-Protection":"1; mode=block","X-Frame-Options":"allowall","Content-Language":"und"},"status_code":200}', 2, NULL, NULL),
(42, 'CHINABOND-CGB10Y|2026/10/01 18:30', '2026-10-01T18:30:07.828+08:00', '重复未入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Set-Cookie":"JSESSIONID=E859538436626D4924EE529372BE3149; Path=/cbweb-pbc-web; HttpOnly","Connection":"keep-alive","Date":"Thu, 01 Oct 2026 10:30:10 GMT","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall","Content-Language":"und","Expect-Ct":"enforce; max-age=86400","X-Xss-Protection":"1; mode=block","Vary":"Accept-Encoding","Content-Type":"text/html;charset=UTF-8"},"status_code":200,"$startTime":1790850609639,"$endTime":1790850610316}', 2, NULL, NULL),
(45, 'CHINABOND-CGB10Y|2026/10/02 18:30', '2026-10-02T18:30:07.477+08:00', '重复未入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Connection":"keep-alive","Expect-Ct":"enforce; max-age=86400","Strict-Transport-Security":"max-age=30; includeSubDomains;","Vary":"Accept-Encoding","X-Xss-Protection":"1; mode=block","Date":"Fri, 02 Oct 2026 10:30:11 GMT","Content-Language":"und","Content-Type":"text/html;charset=UTF-8","Set-Cookie":"JSESSIONID=3044D97B98E835A8889C6062BC80D294; Path=/cbweb-pbc-web; HttpOnly","X-Frame-Options":"allowall","X-Content-Type-Options":"nosniff"},"status_code":200,"$startTime":1790937010588,"$endTime":1790937011416}', 2, NULL, NULL),
(47, 'CHINABOND-CGB10Y|2026/10/03 18:30', '2026-10-03T18:30:03.012+08:00', '重复未入库', '{"status_code":200,"$startTime":1791023406166,"$endTime":1791023407466,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Content-Type":"text/html;charset=UTF-8","Vary":"Accept-Encoding","Set-Cookie":"JSESSIONID=D8903ADDB391C43AFFFBC2C45F637664; Path=/cbweb-pbc-web; HttpOnly","Expect-Ct":"enforce; max-age=86400","X-Frame-Options":"allowall","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Xss-Protection":"1; mode=block","Connection":"keep-alive","Date":"Sat, 03 Oct 2026 10:30:07 GMT","Content-Language":"und","X-Content-Type-Options":"nosniff"}}', 2, NULL, NULL),
(50, 'CHINABOND-CGB10Y|2026/10/04 18:30', '2026-10-04T18:30:06.165+08:00', '重复未入库', '{"headers":{"X-Xss-Protection":"1; mode=block","Set-Cookie":"JSESSIONID=0053EAD744B2F42E41555B68163241F3; Path=/cbweb-pbc-web; HttpOnly","Vary":"Accept-Encoding","X-Content-Type-Options":"nosniff","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","Date":"Sun, 04 Oct 2026 10:30:09 GMT","Strict-Transport-Security":"max-age=30; includeSubDomains;","Content-Language":"und","X-Frame-Options":"allowall","Connection":"keep-alive"},"status_code":200,"$startTime":1791109808889,"$endTime":1791109809470,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(52, 'CHINABOND-CGB10Y|2026/10/05 18:30', '2026-10-05T18:30:04.252+08:00', '重复未入库', '{"headers":{"X-Content-Type-Options":"nosniff","Set-Cookie":"JSESSIONID=5525A1B60F7EE14D87F76808DDCB4CA7; Path=/cbweb-pbc-web; HttpOnly","Content-Language":"und","X-Frame-Options":"allowall","X-Xss-Protection":"1; mode=block","Strict-Transport-Security":"max-age=30; includeSubDomains;","Connection":"keep-alive","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","Vary":"Accept-Encoding","Date":"Mon, 05 Oct 2026 10:30:08 GMT"},"status_code":200,"$startTime":1791196207573,"$endTime":1791196208554,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(56, 'CHINABOND-CGB10Y|2026/10/06 18:30', '2026-10-06T18:30:05.484+08:00', '重复未入库', '{"$startTime":1791282608038,"$endTime":1791282609542,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Connection":"keep-alive","Content-Type":"text/html;charset=UTF-8","Content-Language":"und","Expect-Ct":"enforce; max-age=86400","X-Content-Type-Options":"nosniff","X-Xss-Protection":"1; mode=block","Date":"Tue, 06 Oct 2026 10:30:09 GMT","Set-Cookie":"JSESSIONID=BB34758FF8709E4C20FD2CF7660F1946; Path=/cbweb-pbc-web; HttpOnly","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Frame-Options":"allowall","Vary":"Accept-Encoding"},"status_code":200}', 2, NULL, NULL),
(60, 'CHINABOND-CGB10Y|2026/10/07 18:30', '2026-10-07T18:30:03.545+08:00', '重复未入库', '{"headers":{"Connection":"keep-alive","X-Frame-Options":"allowall","Expect-Ct":"enforce; max-age=86400","Content-Language":"und","Content-Type":"text/html;charset=UTF-8","X-Content-Type-Options":"nosniff","Vary":"Accept-Encoding","X-Xss-Protection":"1; mode=block","Date":"Wed, 07 Oct 2026 10:30:08 GMT","Set-Cookie":"JSESSIONID=A50CFF2521FBFA042FBBE00548BDD343; Path=/cbweb-pbc-web; HttpOnly","Strict-Transport-Security":"max-age=30; includeSubDomains;"},"status_code":200,"$startTime":1791369006910,"$endTime":1791369008367,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-09-30\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-09-30(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9043 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1916</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2197</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2818</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4090</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5101</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6822</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1000</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3241 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4437</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4753</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5522</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5668</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8456</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4351 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4408</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4823</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6320</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9500</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(62, 'CHINABOND-CGB10Y|2026/10/08 18:30', '2026-10-08T18:30:04.911+08:00', '已入库', '{"status_code":200,"$startTime":1791455408957,"$endTime":1791455410516,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-08\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-08(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9000 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1611</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1940</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2282</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2851</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4128</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5194</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6899</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.1060</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3141 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4462</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4780</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5492</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5751</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6942</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8556</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4400</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4790</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4953</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6279</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6874</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8006</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9567</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Expect-Ct":"enforce; max-age=86400","X-Content-Type-Options":"nosniff","Content-Language":"und","Content-Type":"text/html;charset=UTF-8","Set-Cookie":"JSESSIONID=33FF0E6C6F08F22E63C66329F263BD8D; Path=/cbweb-pbc-web; HttpOnly","X-Frame-Options":"allowall","X-Xss-Protection":"1; mode=block","Connection":"keep-alive","Date":"Thu, 08 Oct 2026 10:30:10 GMT","Strict-Transport-Security":"max-age=30; includeSubDomains;","Vary":"Accept-Encoding"}}', 2, NULL, NULL),
(65, 'CHINABOND-CGB10Y|2026/10/09 18:30', '2026-10-09T18:30:05.495+08:00', '已入库', '{"$startTime":1791541809786,"$endTime":1791541810541,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-09\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-09(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9179 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1705</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1965</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2172</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2816</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4089</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5135</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6864</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0915</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3141 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4144</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4456</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4767</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5484</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5752</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7008</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8535</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4350 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4392</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4623</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4941</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6233</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6840</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8072</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9550</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Set-Cookie":"JSESSIONID=295A926140C046311DD2C449E544E2F6; Path=/cbweb-pbc-web; HttpOnly","Expect-Ct":"enforce; max-age=86400","Date":"Fri, 09 Oct 2026 10:30:10 GMT","Connection":"keep-alive","Vary":"Accept-Encoding","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Xss-Protection":"1; mode=block","X-Content-Type-Options":"nosniff","Content-Language":"und","X-Frame-Options":"allowall","Content-Type":"text/html;charset=UTF-8"},"status_code":200}', 2, NULL, NULL),
(67, 'CHINABOND-CGB10Y|2026/10/10 18:30', '2026-10-10T18:30:03.957+08:00', '已入库', '{"status_code":200,"$startTime":1791628207315,"$endTime":1791628208572,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-10\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-10(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9240 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1680</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1940</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2147</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2803</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4069</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5103</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6849</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0870</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3141 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4144</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4399</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4718</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5518</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5727</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8582</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4458</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4500</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4994</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6252</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6874</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8114</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9600</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Vary":"Accept-Encoding","Expect-Ct":"enforce; max-age=86400","Set-Cookie":"JSESSIONID=B61E415A1BC142AEA489DA1CB50604E0; Path=/cbweb-pbc-web; HttpOnly","Content-Type":"text/html;charset=UTF-8","X-Frame-Options":"allowall","Strict-Transport-Security":"max-age=30; includeSubDomains;","Content-Language":"und","Date":"Sat, 10 Oct 2026 10:30:08 GMT","X-Xss-Protection":"1; mode=block","Connection":"keep-alive","X-Content-Type-Options":"nosniff"}}', 2, NULL, NULL),
(70, 'CHINABOND-CGB10Y|2026/10/11 18:30', '2026-10-11T18:30:01.603+08:00', '重复未入库', '{"$startTime":1791714605318,"$endTime":1791714606514,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-10\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-10(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9240 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1680</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1940</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2147</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2803</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4069</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5103</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6849</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0870</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3141 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4144</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4399</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4718</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5518</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5727</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7050</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8582</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2825</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4400 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4458</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4500</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4994</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6252</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6874</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8114</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9600</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Vary":"Accept-Encoding","Content-Type":"text/html;charset=UTF-8","Date":"Sun, 11 Oct 2026 10:30:06 GMT","Connection":"keep-alive","Content-Language":"und","X-Frame-Options":"allowall","Set-Cookie":"JSESSIONID=24AB9C98D33CE3DFF7F6C6C7EC902CFD; Path=/cbweb-pbc-web; HttpOnly","X-Content-Type-Options":"nosniff","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Xss-Protection":"1; mode=block","Expect-Ct":"enforce; max-age=86400"},"status_code":200}', 2, NULL, NULL),
(74, 'CHINABOND-CGB10Y|2026/10/12 18:30', '2026-10-12T18:30:01.943+08:00', '已入库', '{"$endTime":1791801006361,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-12\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-12(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9399 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1655</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1896</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2047</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2774</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4024</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4965</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6722</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0670</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3141 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4125</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4281</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4596</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5469</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5645</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6899</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8443</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2705</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4300 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4436</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4500</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4892</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6148</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6830</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8074</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9470</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"X-Frame-Options":"allowall","Content-Language":"und","Expect-Ct":"enforce; max-age=86400","X-Xss-Protection":"1; mode=block","X-Content-Type-Options":"nosniff","Content-Type":"text/html;charset=UTF-8","Set-Cookie":"JSESSIONID=3CCE9E09E9693D101214E5C9CAB181F3; Path=/cbweb-pbc-web; HttpOnly","Strict-Transport-Security":"max-age=30; includeSubDomains;","Connection":"keep-alive","Date":"Mon, 12 Oct 2026 10:30:06 GMT","Vary":"Accept-Encoding"},"status_code":200,"$startTime":1791801005577}', 2, NULL, NULL),
(77, 'CHINABOND-CGB10Y|2026/10/13 18:30', '2026-10-13T18:30:06.444+08:00', '已入库', '{"status_code":200,"$startTime":1791887409777,"$endTime":1791887410402,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-13\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-13(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9649 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1630</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1819</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1947</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2748</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3974</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4897</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6654</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0690</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3141 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4150</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4380</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4620</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5463</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5598</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6806</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8345</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2605</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4050 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4400</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4499</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4838</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6128</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6810</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7937</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9405</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Content-Language":"und","Vary":"Accept-Encoding","Connection":"keep-alive","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","Date":"Tue, 13 Oct 2026 10:30:10 GMT","Set-Cookie":"JSESSIONID=CBB3959D47BCDB79F425B513181AA3B9; Path=/cbweb-pbc-web; HttpOnly","X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Xss-Protection":"1; mode=block"}}', 2, NULL, NULL),
(81, 'CHINABOND-CGB10Y|2026/10/14 18:30', '2026-10-14T18:30:05.06+08:00', '已入库', '{"headers":{"Content-Type":"text/html;charset=UTF-8","Vary":"Accept-Encoding","Strict-Transport-Security":"max-age=30; includeSubDomains;","Content-Language":"und","X-Frame-Options":"allowall","Expect-Ct":"enforce; max-age=86400","X-Xss-Protection":"1; mode=block","Connection":"keep-alive","X-Content-Type-Options":"nosniff","Date":"Wed, 14 Oct 2026 10:30:10 GMT","Set-Cookie":"JSESSIONID=7D3628DB35DE7E4BD27C549EE494D083; Path=/cbweb-pbc-web; HttpOnly"},"status_code":200,"$startTime":1791973808520,"$endTime":1791973810394,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-14\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-14(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9331 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1699</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1700</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1872</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2720</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3896</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4838</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6516</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0600</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3041 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4162</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4345</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4594</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5409</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5586</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6712</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8263</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2505</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4055 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4422</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4707</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4814</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6066</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6775</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7810</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9190</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(83, 'CHINABOND-CGB10Y|2026/10/15 18:30', '2026-10-15T18:30:06.238+08:00', '已入库', '{"status_code":200,"$startTime":1792060210023,"$endTime":1792060211363,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-15\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-15(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9331 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1618</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1625</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1803</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2694</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3900</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4866</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6601</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0700</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3041 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4150</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4294</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4534</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5374</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5514</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6708</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8041</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2505</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4055 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4322</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4694</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4794</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5965</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6680</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7807</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.9000</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Xss-Protection":"1; mode=block","Vary":"Accept-Encoding","X-Content-Type-Options":"nosniff","Set-Cookie":"JSESSIONID=431E409F8689E222A27C99D6DA07DC3C; Path=/cbweb-pbc-web; HttpOnly","X-Frame-Options":"allowall","Content-Language":"und","Date":"Thu, 15 Oct 2026 10:30:11 GMT","Expect-Ct":"enforce; max-age=86400","Content-Type":"text/html;charset=UTF-8","Connection":"keep-alive"}}', 2, NULL, NULL),
(86, 'CHINABOND-CGB10Y|2026/10/16 18:30', '2026-10-16T18:30:05.052+08:00', '已入库', '{"headers":{"X-Content-Type-Options":"nosniff","X-Frame-Options":"allowall","Connection":"keep-alive","Content-Language":"und","Vary":"Accept-Encoding","Strict-Transport-Security":"max-age=30; includeSubDomains;","Content-Type":"text/html;charset=UTF-8","Date":"Fri, 16 Oct 2026 10:30:09 GMT","Expect-Ct":"enforce; max-age=86400","Set-Cookie":"JSESSIONID=3D87A18BB85C312E68930D5A2D69DA50; Path=/cbweb-pbc-web; HttpOnly","X-Xss-Protection":"1; mode=block"},"status_code":200,"$startTime":1792146608779,"$endTime":1792146609544,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-16\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-16(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9331 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1568</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1587</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1703</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2729</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3815</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4700</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6480</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0600</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3041 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4100</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4217</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4520</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5331</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5504</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6717</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8006</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2505</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4055 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4402</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4657</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4764</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6673</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7815</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8976</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(90, 'CHINABOND-CGB10Y|2026/10/17 18:30', '2026-10-17T18:30:05.302+08:00', '重复未入库', '{"$startTime":1792233008971,"$endTime":1792233010492,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-16\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-16(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9331 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1568</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1587</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1703</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2729</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3815</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4700</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6480</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0600</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3041 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4100</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4217</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4520</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5331</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5504</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6717</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8006</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2505</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4055 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4402</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4657</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4764</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6673</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7815</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8976</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Set-Cookie":"JSESSIONID=0AD014FA9D59CCC5255436AB20FF8F26; Path=/cbweb-pbc-web; HttpOnly","Vary":"Accept-Encoding","Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","X-Content-Type-Options":"nosniff","Content-Language":"und","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Frame-Options":"allowall","Date":"Sat, 17 Oct 2026 10:30:10 GMT","Connection":"keep-alive","X-Xss-Protection":"1; mode=block"},"status_code":200}', 2, NULL, NULL),
(92, 'CHINABOND-CGB10Y|2026/10/18 18:30', '2026-10-18T18:30:03.692+08:00', '重复未入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-16\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-16(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9331 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1568</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1587</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1703</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2729</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3815</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4700</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6480</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0600</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.3041 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4100</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4217</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4520</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5331</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5504</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6717</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8006</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2505</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4055 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4402</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4657</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4764</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5918</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6673</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7815</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8976</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Date":"Sun, 18 Oct 2026 10:30:07 GMT","X-Frame-Options":"allowall","Vary":"Accept-Encoding","Expect-Ct":"enforce; max-age=86400","Strict-Transport-Security":"max-age=30; includeSubDomains;","X-Content-Type-Options":"nosniff","Content-Language":"und","Set-Cookie":"JSESSIONID=504D53737C916754E47354A41D205D78; Path=/cbweb-pbc-web; HttpOnly","Connection":"keep-alive","Content-Type":"text/html;charset=UTF-8","X-Xss-Protection":"1; mode=block"},"status_code":200,"$startTime":1792319406308,"$endTime":1792319407383}', 2, NULL, NULL),
(96, 'CHINABOND-CGB10Y|2026/10/19 18:30', '2026-10-19T18:30:07.533+08:00', '已入库', '{"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-19\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-19(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9331 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1750</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1752</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1813</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2674</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3770</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4673</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6497</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0610</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.2987 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4125</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4217</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4512</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5330</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5507</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6542</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8049</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2405</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4200 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4381</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4627</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4775</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5921</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6700</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7640</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8975</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Content-Type":"text/html;charset=UTF-8","Expect-Ct":"enforce; max-age=86400","Connection":"keep-alive","X-Xss-Protection":"1; mode=block","Content-Language":"und","Date":"Mon, 19 Oct 2026 10:30:11 GMT","Strict-Transport-Security":"max-age=30; includeSubDomains;","Vary":"Accept-Encoding","X-Content-Type-Options":"nosniff","Set-Cookie":"JSESSIONID=A8747651ADCD298B45A0CB7F3AB971F2; Path=/cbweb-pbc-web; HttpOnly","X-Frame-Options":"allowall"},"status_code":200,"$startTime":1792405810183,"$endTime":1792405811595}', 2, NULL, NULL),
(98, 'CHINABOND-CGB10Y|2026/10/20 18:30', '2026-10-20T18:30:06.803+08:00', '已入库', '{"$endTime":1792492210378,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-20\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-20(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9031 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1675</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1602</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1765</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2628</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3476</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4421</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6354</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0510</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.2687 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4057</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4065</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4290</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5094</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5326</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6331</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7838</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2305</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4256 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4252</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4452</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4631</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5751</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6519</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7497</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8801</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>","headers":{"Strict-Transport-Security":"max-age=30; includeSubDomains;","Vary":"Accept-Encoding","X-Content-Type-Options":"nosniff","Connection":"keep-alive","Content-Type":"text/html;charset=UTF-8","Set-Cookie":"JSESSIONID=B1F5CC39480F9F8DA384AF236AAD40D6; Path=/cbweb-pbc-web; HttpOnly","X-Frame-Options":"allowall","X-Xss-Protection":"1; mode=block","Expect-Ct":"enforce; max-age=86400","Content-Language":"und","Date":"Tue, 20 Oct 2026 10:30:10 GMT"},"status_code":200,"$startTime":1792492209103}', 2, NULL, NULL),
(100, 'CHINABOND-CGB10Y|2026/10/21 18:30', '2026-10-21T18:30:04.733+08:00', '已入库', '{"headers":{"Strict-Transport-Security":"max-age=30; includeSubDomains;","Set-Cookie":"JSESSIONID=B3AB17FEFF43FE6130615099C5DED165; Path=/cbweb-pbc-web; HttpOnly","Content-Type":"text/html;charset=UTF-8","X-Frame-Options":"allowall","Content-Language":"und","Date":"Wed, 21 Oct 2026 10:30:09 GMT","Expect-Ct":"enforce; max-age=86400","X-Content-Type-Options":"nosniff","Vary":"Accept-Encoding","X-Xss-Protection":"1; mode=block","Connection":"keep-alive"},"status_code":200,"$startTime":1792578607982,"$endTime":1792578609428,"body":"\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\r\n<html>\r\n<head>\r\n\t<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\r\n\t\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n <script type=\"text/javascript\" >\r\n        var ctx=\"/cbweb-pbc-web\";\r\n        var ctxStatics=\"/cbweb-pbc-web/statics\";\r\n </script>\r\n\r\n\r\n\r\n\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n<meta http-equiv=\"Cache-Control\" content=\"no-store\" /><meta http-equiv=\"Pragma\" content=\"no-cache\" />\n<meta http-equiv=\"Expires\" content=\"0\" />\n<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />\n<script src=\"/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js\"></script>\n<script type=\"text/javascript\" src=\"/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js\"></script>\n<script src=\"/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js\" type=\"text/javascript\"></script>\n\r\n<title>国债及其他债券收益率曲线</title>\r\n \r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/cbweb-pbc-web/statics/css/indexCn.css\" id=\"css\" />\r\n\r\n   \r\n<script src=\"/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/custom/statusCheck.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\t\r\n<script src=\"/cbweb-pbc-web/statics/js/higchart/colorArr.js\"\r\n\ttype=\"text/javascript\"></script>\r\n\r\n</head>\r\n<body>\r\n\t<div id=\"Container\">\r\n\t\t<div id=\"Header\">\r\n\t\t\t   <div id=\"title\"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>\r\n\t           <div id=\"ytitle\">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>\r\n\t\t</div>\r\n\t\t<div class=\"Clear\"></div>\r\n\t\t<div id=\"Content\">\r\n\t\t\t<div id=\"dateText\"><!-- 日期 -->日期:</div>\r\n\t\t\t<div id=\"datePop\">\r\n\t\t\t    \r\n\t\t        \r\n\t\t            <input name=\"gzr\" id=\"gzr\" type=\"text\" class=\"date\" value=\"2026-10-21\"\r\n\t\t\t\t\t\t\tonclick=\"WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false\r\n\t\t\t\t\t\t\t ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});\" />\r\n\t\t        \r\n\t\t\t</div>\r\n\t\t\t<div id=\"searchBut\">\r\n\t\t\t    <input type=\"button\" value=\"查询\" onclick=\"query()\"/>\r\n\t\t\t\t<input type=\"button\" value=\"历史数据\" onclick=\"historyQuery()\"/>\r\n\t\t\t</div>\r\n\t\t</div>\r\n\t\t\r\n\t\t<div id = \"graph\" class=\"graph\" align=\"left\"></div>\r\n\t\t   \r\n\t\t<div id=\"gjqxData\">\r\n\t\t\t<table  border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n\t\t\t\t <tr>\r\n\t\t\t\t \r\n\t\t\t\t    <th>2026-10-21(%)</th>\r\n\t\t\t\t\t<!--<th style=\"border-left:1px solid #000000\"> 隔夜 隔夜</th>-->\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">6<!-- 月 -->月</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">1<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">3<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">5<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">7<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">10<!-- 年 -->年</th>\r\n\t\t\t\t    <th style=\"border-left:1px solid #000000\">30<!-- 年 -->年</th>\r\n\t\t\t\t</tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债国债收益率曲线</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">0.9031 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.1601</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1627</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.1793</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.2653</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.3557</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4554</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6412</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.0630</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债商业银行普通债收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.2537 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.3857</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4010</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4288</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5018</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5291</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6336</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7814</td>\r\n                       <td style=\"border-left:1px solid #000000\">2.2305</td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t\t    <tr>\r\n\t\t\t\t       <td style=\"width: 250px;text-align: left; line-height: 1\">中债中短期票据收益率曲线(AAA)</td>\r\n                      <!--  <td style=\"border-left:1px solid #000000\">1.4000 </td> -->\r\n                       <td style=\"border-left:1px solid #000000\">1.4180</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4357</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.4574</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.5641</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.6455</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.7495</td>\r\n                       <td style=\"border-left:1px solid #000000\">1.8800</td>\r\n                       <td style=\"border-left:1px solid #000000\"></td>\r\n\t\t\t\t    </tr>\r\n\t\t\t\t\r\n\t\t\t</table>\r\n\t\t</div>\r\n\t\t<div id=\"zhu\"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>\r\n\t\t<div id=\"font1\">\r\n\t\t\t\r\n\t\t\t\t<div style=\"font-weight:bold; text-align: center;\">\r\n\t\t               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介\r\n\t\t    \t</div>\r\n\t\t\t\r\n\t\t      <div>\r\n\t\t         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。\r\n\t\t                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->\r\n\t\t                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。\r\n\t\t      </div>\r\n\t\t      <div>\r\n\t\t        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、\r\n\t\t                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->\r\n\t\t                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。\r\n\t\t     </div>\r\n\t\t</div>\r\n\t</div>\r\n\t<input type=\"hidden\" id=\"locale\" value=\"cn_ZH\">\r\n</body>\r\n\r\n<script type=\"text/javascript\">\r\n\r\n    Highcharts.setOptions({\r\n        global: {\r\n            useUTC: false\r\n        },\r\n    });\r\n    var chart = null;\r\n    var xData=new Array();\r\n    var options = {\r\n        chart : {\r\n            exporting : {\r\n                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示\r\n            },\r\n            renderTo : ''graph'',\r\n            type: ''line'',\r\n            marginBottom : 90,\r\n            marginTop : 5,\r\n            marginLeft : 50,\r\n        },\r\n        title : {\r\n            text : ''''\r\n        },\r\n        xAxis : {\r\n            labels:{\r\n                style:{\r\n                    fontSize:''10px'',\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            crosshair: {\r\n                width: 1,\r\n                color: ''#CC0000''\r\n            },\r\n            categories:xData,\r\n            tickPositions: [0,10, 20,30, 50,70,110],\r\n            tickWidth : 1,\r\n            gridLineWidth : 1,\r\n            lineWidth : 1,\r\n            lineColor : ''black'',\r\n            showFirstLabel : true,\r\n            showLastLable : true,\r\n            tickLength : 0,\r\n        },\r\n\r\n        yAxis : [ {\r\n            labels : {\r\n                format : ''{value:.,0f}'',\r\n                padding : 50,\r\n                x : -10,\r\n                formatter : function(){\r\n                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几\r\n                },\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            title : {\r\n                text : ''(%)'',\r\n                align: ''high'',\r\n                offset: 5,\r\n                rotation:0,\r\n                y: 85,\r\n                x: -30,\r\n                style:{\r\n                    fontWeight:\"normal\",\r\n                    fontSize: \"10px\",\r\n                    fontFamily: \"宋体\",\r\n                    color: \"#333333\",\r\n                }\r\n            },\r\n            tickPixelInterval: 50,\r\n            allowDecimals : true,//是否显示小数\r\n            showFirstLabel : true,\r\n            tickPosition : ''outside'',\r\n            tickLength : 3,\r\n            opposite : false,//设置y轴在对面显示\r\n            lineWidth : 1,//设置y轴的线宽\r\n            tickWidth : 1,\r\n            tickColor : ''black'',\r\n            lineColor : ''black'',\r\n        } ],\r\n\r\n        legend : {\r\n            enabled : true,\r\n            align: ''left'',\r\n            layout: ''vertical'',\r\n            floating: true,\r\n            itemMarginTop: 3,\r\n            x: 45,\r\n            y: 10,\r\n            itemStyle: {\r\n                fontWeight:\"normal\",\r\n                fontSize: \"12px\",\r\n                fontFamily: \"宋体\",\r\n                color: \"#333333\",\r\n                cursor: \"default\",\r\n            },\r\n        },\r\n        credits : {\r\n            enabled : false //去掉higcharts.com\r\n        },\r\n        tooltip : {\r\n            shared : false,\r\n            split : true,\r\n            animation : false,\r\n            shape : ''square'',\r\n            crosshairs : {\r\n                width : 1,\r\n                color : ''red''\r\n            },\r\n            distance : 3,//距离某个点的距离\r\n            useHTML : true,\r\n            borderWidth : 1,\r\n            headerFormat : ''<small style=\"background-color:#DC143C\">{point.key}</small><table border=\"5\">'',\r\n            pointFormat : ''<tr><td style=\"text-align: right,color:{point.color}\">{point.y:.4f}%</td></tr>'',\r\n            footerFormat : ''</table>'',\r\n        },\r\n        plotOptions : {\r\n            series: {\r\n                animation:false,\r\n                states:{\r\n                    hover:{\r\n                        lineWidthPlus: 0\r\n                    },\r\n                },\r\n                marker:{\r\n                    symbol:''circle'',\r\n                    enabled:true,\r\n                    radius:0.1\r\n                },\r\n                connectNulls:true,//连接空点\r\n            },\r\n        },\r\n        series : []\r\n    }\r\n    function query(){\r\n        queryGjqxInfo();\r\n\r\n        var workTime=document.getElementById(\"gzr\").value;\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/query?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    var url = window.location.href;\r\n    var locale=url.substring(url.indexOf(\"=\") + 1, url.length).split(''&'');\r\n\tif ( locale !== ''en_US'') {\r\n\t\tlocale = ''zh_CN''\r\n\t}\r\n\r\n    function queryGjqxInfo(){\r\n        var workTime = [document.getElementById(\"gzr\").value];\r\n\t\tvar locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime=\"+workTime+\"&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            dataType : \"html\",\r\n            success : function(data) {\r\n                $(\"#gjqxData\").html(data);\r\n            }\r\n        });\r\n    }\r\n\r\n\r\n\r\n    function historyQuery(){\r\n    \tvar localeValue = document.getElementById(''locale'').value;\r\n\t\tif(localeValue ==\"en_US\" ){\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}else{\r\n\t\t\twindow.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');\r\n\t\t}\r\n    }\r\n\r\n\r\n\r\n    function showInfo(msgInfo,title){\r\n        alert(msgInfo);\r\n    }\r\n\r\n    var zero;\r\n    var year;\r\n    var month;\r\n    var dataNullMsg;\r\n    var LoadingDataFailedMsg;\r\n    $(document).ready(function(){\r\n        if(false){\r\n            zero = \"O/N\";\r\n            year = \"Y\";\r\n            month = \"M\";\r\n            dataNullMsg = \"No matched yield curve is found,please trying other searching criteria.\";\r\n            LoadingDataFailedMsg = \"Loading data failed\";\r\n        }else{\r\n            zero = \"0\";\r\n            year = \"年\";\r\n            month = \"月\";\r\n            dataNullMsg = \"没有查询到曲线,请重新输入查询条件\";\r\n            LoadingDataFailedMsg = \"取得数据失败\";\r\n        }\r\n\r\n        pbcInit();\r\n    });\r\n\r\n    function pbcInit(){\r\n        var locale = document.getElementById(''locale'').value;\r\n        var url = \"/cbweb-pbc-web/pbc/pbcInit?&locale=\"+locale;\r\n\r\n        $.ajax({\r\n            type : \"post\",\r\n            url : url,\r\n            cache : false,\r\n            success : function(data) {\r\n                createGraph(data);\r\n            },\r\n            error : function() {\r\n                alert(LoadingDataFailedMsg);\r\n                $(''#graph'').html(\"\");\r\n                return;\r\n            }\r\n        });\r\n    }\r\n\r\n    function createGraph(data){\r\n\r\n        if(data == null || data.length == 0){\r\n            alert(dataNullMsg);\r\n            $(''#graph'').html(\"\");\r\n            return;\r\n        }\r\n\r\n        var tempData;\r\n\r\n        options.series = new Array();\r\n        for(var i = 0; i < data.length; i++){\r\n            var yData = new Array();\r\n            options.series[i]=new Object();\r\n\r\n            tempData = data[i].seriesData;\r\n            for(var j = 0; j < tempData.length; j++){\r\n\r\n                var xValue = tempData[j][0];\r\n                if(xValue == 0){\r\n                    xData.push(zero);\r\n                }else if(xValue > 0 && xValue < 1){\r\n                    xData.push(xValue * 12 + month);\r\n                }else if(xValue >= 1){\r\n                    xData.push(xValue + year);\r\n                }else{\r\n                    xData.push(xValue);\r\n                }\r\n\r\n                var yValue;\r\n                if(xValue < 0.25){\r\n                    yValue = \"\";\r\n                }else{\r\n                    yValue = Number(tempData[j][1]);\r\n                }\r\n                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3\r\n                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){\r\n                    yData.push({y:yValue,marker:{radius:2}});\r\n                }else{\r\n                    yData.push(yValue);\r\n                }\r\n                options.series[i].data = yData;\r\n                options.series[i].name = data[i].ycDefName;\r\n                options.series[i].color = colorArr[i];\r\n                options.series[i].dataGrouping = {enabled : false};\r\n                options.series[i].lineWidth = 1;\r\n            }\r\n\r\n        }\r\n\r\n        chart = new Highcharts.Chart(options);\r\n    }\r\n\r\n</script>\r\n</html>"}', 2, NULL, NULL),
(106, '中债国债10年收益率｜2026-10-21T15:35:24.686Z', '2026-10-21T23:35:24.686+08:00', '抓取失败', NULL, 2, 'HTTP Client network socket disconnected before secure TLS connection was established', NULL),
(109, '中债国债10年收益率｜手动', '2026-10-22T08:16:43.09+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-21"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-21(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9031 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1627</td>
                       <td style="border-left:1px solid #000000">1.1793</td>
                       <td style="border-left:1px solid #000000">1.2653</td>
                       <td style="border-left:1px solid #000000">1.3557</td>
                       <td style="border-left:1px solid #000000">1.4554</td>
                       <td style="border-left:1px solid #000000">1.6412</td>
                       <td style="border-left:1px solid #000000">2.0630</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2537 </td> -->
                       <td style="border-left:1px solid #000000">1.3857</td>
                       <td style="border-left:1px solid #000000">1.4010</td>
                       <td style="border-left:1px solid #000000">1.4288</td>
                       <td style="border-left:1px solid #000000">1.5018</td>
                       <td style="border-left:1px solid #000000">1.5291</td>
                       <td style="border-left:1px solid #000000">1.6336</td>
                       <td style="border-left:1px solid #000000">1.7814</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4180</td>
                       <td style="border-left:1px solid #000000">1.4357</td>
                       <td style="border-left:1px solid #000000">1.4574</td>
                       <td style="border-left:1px solid #000000">1.5641</td>
                       <td style="border-left:1px solid #000000">1.6455</td>
                       <td style="border-left:1px solid #000000">1.7495</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(112, '中债国债10年收益率｜手动', '2026-10-22T08:20:04.466+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-21"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-21(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9031 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1627</td>
                       <td style="border-left:1px solid #000000">1.1793</td>
                       <td style="border-left:1px solid #000000">1.2653</td>
                       <td style="border-left:1px solid #000000">1.3557</td>
                       <td style="border-left:1px solid #000000">1.4554</td>
                       <td style="border-left:1px solid #000000">1.6412</td>
                       <td style="border-left:1px solid #000000">2.0630</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2537 </td> -->
                       <td style="border-left:1px solid #000000">1.3857</td>
                       <td style="border-left:1px solid #000000">1.4010</td>
                       <td style="border-left:1px solid #000000">1.4288</td>
                       <td style="border-left:1px solid #000000">1.5018</td>
                       <td style="border-left:1px solid #000000">1.5291</td>
                       <td style="border-left:1px solid #000000">1.6336</td>
                       <td style="border-left:1px solid #000000">1.7814</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4180</td>
                       <td style="border-left:1px solid #000000">1.4357</td>
                       <td style="border-left:1px solid #000000">1.4574</td>
                       <td style="border-left:1px solid #000000">1.5641</td>
                       <td style="border-left:1px solid #000000">1.6455</td>
                       <td style="border-left:1px solid #000000">1.7495</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(115, '中债国债10年收益率｜手动', '2026-10-22T09:02:34.117+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-21"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-21(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9031 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1627</td>
                       <td style="border-left:1px solid #000000">1.1793</td>
                       <td style="border-left:1px solid #000000">1.2653</td>
                       <td style="border-left:1px solid #000000">1.3557</td>
                       <td style="border-left:1px solid #000000">1.4554</td>
                       <td style="border-left:1px solid #000000">1.6412</td>
                       <td style="border-left:1px solid #000000">2.0630</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2537 </td> -->
                       <td style="border-left:1px solid #000000">1.3857</td>
                       <td style="border-left:1px solid #000000">1.4010</td>
                       <td style="border-left:1px solid #000000">1.4288</td>
                       <td style="border-left:1px solid #000000">1.5018</td>
                       <td style="border-left:1px solid #000000">1.5291</td>
                       <td style="border-left:1px solid #000000">1.6336</td>
                       <td style="border-left:1px solid #000000">1.7814</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4180</td>
                       <td style="border-left:1px solid #000000">1.4357</td>
                       <td style="border-left:1px solid #000000">1.4574</td>
                       <td style="border-left:1px solid #000000">1.5641</td>
                       <td style="border-left:1px solid #000000">1.6455</td>
                       <td style="border-left:1px solid #000000">1.7495</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(118, '纸浆期货（新浪 SP0）｜手动', '2026-10-22T09:02:34.827+08:00', '已入库', 'var hq_str_nf_SP0="ֽ������,090227,4676.000,4694.000,4660.000,0.000,4684.000,4686.000,4684.000,0.000,4670.000,65,108,368483.000,110271,��,ֽ��,2026-10-22,1,,,,,,,,,4675.307,4682.000,180,4680.000,350,4678.000,178,4676.000,150,4688.000,190,4690.000,249,4692.000,372,4694.000,325";
', 5, 'HTTP 200  ', NULL),
(120, '中债国债10年收益率｜手动', '2026-10-22T19:05:16.126+08:00', '已入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-22"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-22(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9033 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1630</td>
                       <td style="border-left:1px solid #000000">1.1794</td>
                       <td style="border-left:1px solid #000000">1.2667</td>
                       <td style="border-left:1px solid #000000">1.3532</td>
                       <td style="border-left:1px solid #000000">1.4562</td>
                       <td style="border-left:1px solid #000000">1.6414</td>
                       <td style="border-left:1px solid #000000">2.0640</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2487 </td> -->
                       <td style="border-left:1px solid #000000">1.3940</td>
                       <td style="border-left:1px solid #000000">1.4047</td>
                       <td style="border-left:1px solid #000000">1.4251</td>
                       <td style="border-left:1px solid #000000">1.4937</td>
                       <td style="border-left:1px solid #000000">1.5284</td>
                       <td style="border-left:1px solid #000000">1.6328</td>
                       <td style="border-left:1px solid #000000">1.7807</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4143</td>
                       <td style="border-left:1px solid #000000">1.4329</td>
                       <td style="border-left:1px solid #000000">1.4515</td>
                       <td style="border-left:1px solid #000000">1.5567</td>
                       <td style="border-left:1px solid #000000">1.6438</td>
                       <td style="border-left:1px solid #000000">1.7375</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(123, '纸浆期货（新浪 SP0）｜手动', '2026-10-22T19:05:17.35+08:00', '已入库', 'var hq_str_nf_SP0="ֽ������,150000,4676.000,4698.000,4628.000,4632.000,4632.000,4634.000,4632.000,4668.000,4670.000,96,42,375427.000,292548,��,ֽ��,2026-10-22,1,,,,,,,,,4668.368,4630.000,89,4628.000,212,4626.000,427,4624.000,1222,4636.000,102,4638.000,368,4640.000,504,4642.000,372";
', 5, 'HTTP 200  ', NULL),
(126, '中债国债10年收益率｜手动', '2026-10-22T20:16:55.59+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-22"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-22(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9033 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1630</td>
                       <td style="border-left:1px solid #000000">1.1794</td>
                       <td style="border-left:1px solid #000000">1.2667</td>
                       <td style="border-left:1px solid #000000">1.3532</td>
                       <td style="border-left:1px solid #000000">1.4562</td>
                       <td style="border-left:1px solid #000000">1.6414</td>
                       <td style="border-left:1px solid #000000">2.0640</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2487 </td> -->
                       <td style="border-left:1px solid #000000">1.3940</td>
                       <td style="border-left:1px solid #000000">1.4047</td>
                       <td style="border-left:1px solid #000000">1.4251</td>
                       <td style="border-left:1px solid #000000">1.4937</td>
                       <td style="border-left:1px solid #000000">1.5284</td>
                       <td style="border-left:1px solid #000000">1.6328</td>
                       <td style="border-left:1px solid #000000">1.7807</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4143</td>
                       <td style="border-left:1px solid #000000">1.4329</td>
                       <td style="border-left:1px solid #000000">1.4515</td>
                       <td style="border-left:1px solid #000000">1.5567</td>
                       <td style="border-left:1px solid #000000">1.6438</td>
                       <td style="border-left:1px solid #000000">1.7375</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(129, '纸浆期货（新浪 SP0）｜手动', '2026-10-22T20:16:56.434+08:00', '重复未入库', 'var hq_str_nf_SP0="ֽ������,150000,4676.000,4698.000,4628.000,4632.000,4632.000,4634.000,4632.000,4668.000,4670.000,96,42,375427.000,292548,��,ֽ��,2026-10-22,1,,,,,,,,,4668.368,4630.000,89,4628.000,212,4626.000,427,4624.000,1222,4636.000,102,4638.000,368,4640.000,504,4642.000,372";
', 5, 'HTTP 200  ', NULL),
(132, '港元兑人民币（腾讯外汇）｜手动', '2026-10-22T20:16:56.96+08:00', '已入库', 'v_whHKDCNY="310~��Ԫ�����~HKDCNY~0.8510~0~20261022201623~0.8504~0.8504~0.8510~0.8503~0.8510~0.8516~0.0006~0.07~-0.15~-0.33~-0.46~-1.45~-5.17~0.9171~0.8503~2026-10-22";
', 10, 'HTTP 200  ', NULL),
(134, '中债国债10年收益率｜手动', '2026-10-23T02:40:16.042+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-22"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-22(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9033 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1630</td>
                       <td style="border-left:1px solid #000000">1.1794</td>
                       <td style="border-left:1px solid #000000">1.2667</td>
                       <td style="border-left:1px solid #000000">1.3532</td>
                       <td style="border-left:1px solid #000000">1.4562</td>
                       <td style="border-left:1px solid #000000">1.6414</td>
                       <td style="border-left:1px solid #000000">2.0640</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2487 </td> -->
                       <td style="border-left:1px solid #000000">1.3940</td>
                       <td style="border-left:1px solid #000000">1.4047</td>
                       <td style="border-left:1px solid #000000">1.4251</td>
                       <td style="border-left:1px solid #000000">1.4937</td>
                       <td style="border-left:1px solid #000000">1.5284</td>
                       <td style="border-left:1px solid #000000">1.6328</td>
                       <td style="border-left:1px solid #000000">1.7807</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4143</td>
                       <td style="border-left:1px solid #000000">1.4329</td>
                       <td style="border-left:1px solid #000000">1.4515</td>
                       <td style="border-left:1px solid #000000">1.5567</td>
                       <td style="border-left:1px solid #000000">1.6438</td>
                       <td style="border-left:1px solid #000000">1.7375</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(137, '纸浆期货（新浪 SP0）｜手动', '2026-10-23T02:40:21.872+08:00', '已入库', 'var hq_str_nf_SP0="ֽ������,230000,4632.000,4662.000,4628.000,0.000,4628.000,4630.000,4630.000,0.000,4668.000,15,24,375169.000,97765,��,ֽ��,2026-10-22,1,,,,,,,,,4642.311,4626.000,359,4624.000,1189,4622.000,492,4620.000,927,4632.000,38,4634.000,135,4636.000,46,4638.000,90";
', 5, 'HTTP 200  ', NULL),
(140, '港元兑人民币（腾讯外汇）｜手动', '2026-10-23T02:40:22.22+08:00', '已入库', 'v_whHKDCNY="310~��Ԫ�����~HKDCNY~0.8513~0~20261023024001~0.8504~0.8504~0.8515~0.8503~0.8513~0.8519~0.0009~0.11~-0.05~-0.14~-0.36~-1.47~-5.14~0.9171~0.8503~2026-10-22";
', 10, 'HTTP 200  ', NULL),
(143, '中债国债10年收益率｜手动', '2026-10-23T12:40:38.746+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-22"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-22(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9033 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1630</td>
                       <td style="border-left:1px solid #000000">1.1794</td>
                       <td style="border-left:1px solid #000000">1.2667</td>
                       <td style="border-left:1px solid #000000">1.3532</td>
                       <td style="border-left:1px solid #000000">1.4562</td>
                       <td style="border-left:1px solid #000000">1.6414</td>
                       <td style="border-left:1px solid #000000">2.0640</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2487 </td> -->
                       <td style="border-left:1px solid #000000">1.3940</td>
                       <td style="border-left:1px solid #000000">1.4047</td>
                       <td style="border-left:1px solid #000000">1.4251</td>
                       <td style="border-left:1px solid #000000">1.4937</td>
                       <td style="border-left:1px solid #000000">1.5284</td>
                       <td style="border-left:1px solid #000000">1.6328</td>
                       <td style="border-left:1px solid #000000">1.7807</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4143</td>
                       <td style="border-left:1px solid #000000">1.4329</td>
                       <td style="border-left:1px solid #000000">1.4515</td>
                       <td style="border-left:1px solid #000000">1.5567</td>
                       <td style="border-left:1px solid #000000">1.6438</td>
                       <td style="border-left:1px solid #000000">1.7375</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL),
(146, '纸浆期货（新浪 SP0）｜手动', '2026-10-23T12:40:39.515+08:00', '已入库', 'var hq_str_nf_SP0="ֽ������,113000,4632.000,4662.000,4592.000,0.000,4628.000,4630.000,4630.000,0.000,4668.000,3,115,371172.000,245679,��,ֽ��,2026-10-23,1,,,,,,,,,4630.954,4626.000,243,4624.000,71,4622.000,110,4620.000,141,4632.000,91,4634.000,90,4636.000,91,4638.000,112";
', 5, 'HTTP 200  ', NULL),
(149, '港元兑人民币（腾讯外汇）｜手动', '2026-10-23T12:40:39.86+08:00', '已入库', 'v_whHKDCNY="310~��Ԫ�����~HKDCNY~0.8507~0~20261023124015~0.8513~0.8513~0.8514~0.8505~0.8507~0.8513~-0.0006~-0.07~-0.12~-0.21~-0.43~-1.54~-5.20~0.9171~0.8503~2026-10-23";
', 10, 'HTTP 200  ', NULL),
(152, '中债国债10年收益率｜手动', '2026-10-23T12:58:36.668+08:00', '重复未入库', '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	








 <script type="text/javascript" >
        var ctx="/cbweb-pbc-web";
        var ctxStatics="/cbweb-pbc-web/statics";
 </script>



	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-store" /><meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<script src="/cbweb-pbc-web/statics/js/jquery/jquery-1.9.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="/cbweb-pbc-web/statics/js/jquery-ztree/jquery.ztree.excheck-3.5.js"></script>
<script src="/cbweb-pbc-web/statics/My97DatePicker/WdatePicker.js" type="text/javascript"></script>

<title>国债及其他债券收益率曲线</title>
 

	<link rel="stylesheet" type="text/css" href="/cbweb-pbc-web/statics/css/indexCn.css" id="css" />

   
<script src="/cbweb-pbc-web/statics/js/My97DatePicker/WdatePicker.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/custom/statusCheck.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/highstock_pbc.js"
	type="text/javascript"></script>
	
<script src="/cbweb-pbc-web/statics/js/higchart/colorArr.js"
	type="text/javascript"></script>

</head>
<body>
	<div id="Container">
		<div id="Header">
			   <div id="title"><!-- 国债及其他收益率曲线 -->国债及其他债券收益率曲线</div>
	           <div id="ytitle">中央国债登记结算有限责任公司编制<!--  中央国债登记结算有限责任公司编制 --></div>
		</div>
		<div class="Clear"></div>
		<div id="Content">
			<div id="dateText"><!-- 日期 -->日期:</div>
			<div id="datePop">
			    
		        
		            <input name="gzr" id="gzr" type="text" class="date" value="2026-10-22"
							onclick="WdatePicker({dateFmt:''yyyy-MM-dd'',isShowClear:false
							 ,isShowToday:false,isShowOK:false,readOnly:true,lang:''zh-cn''});" />
		        
			</div>
			<div id="searchBut">
			    <input type="button" value="查询" onclick="query()"/>
				<input type="button" value="历史数据" onclick="historyQuery()"/>
			</div>
		</div>
		
		<div id = "graph" class="graph" align="left"></div>
		   
		<div id="gjqxData">
			<table  border="0" cellspacing="0" cellpadding="0">
				 <tr>
				 
				    <th>2026-10-22(%)</th>
					<!--<th style="border-left:1px solid #000000"> 隔夜 隔夜</th>-->
				    <th style="border-left:1px solid #000000">3<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">6<!-- 月 -->月</th>
				    <th style="border-left:1px solid #000000">1<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">3<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">5<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">7<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">10<!-- 年 -->年</th>
				    <th style="border-left:1px solid #000000">30<!-- 年 -->年</th>
				</tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债国债收益率曲线</td>
                      <!--  <td style="border-left:1px solid #000000">0.9033 </td> -->
                       <td style="border-left:1px solid #000000">1.1601</td>
                       <td style="border-left:1px solid #000000">1.1630</td>
                       <td style="border-left:1px solid #000000">1.1794</td>
                       <td style="border-left:1px solid #000000">1.2667</td>
                       <td style="border-left:1px solid #000000">1.3532</td>
                       <td style="border-left:1px solid #000000">1.4562</td>
                       <td style="border-left:1px solid #000000">1.6414</td>
                       <td style="border-left:1px solid #000000">2.0640</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债商业银行普通债收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.2487 </td> -->
                       <td style="border-left:1px solid #000000">1.3940</td>
                       <td style="border-left:1px solid #000000">1.4047</td>
                       <td style="border-left:1px solid #000000">1.4251</td>
                       <td style="border-left:1px solid #000000">1.4937</td>
                       <td style="border-left:1px solid #000000">1.5284</td>
                       <td style="border-left:1px solid #000000">1.6328</td>
                       <td style="border-left:1px solid #000000">1.7807</td>
                       <td style="border-left:1px solid #000000">2.2305</td>
				    </tr>
				
				    <tr>
				       <td style="width: 250px;text-align: left; line-height: 1">中债中短期票据收益率曲线(AAA)</td>
                      <!--  <td style="border-left:1px solid #000000">1.4000 </td> -->
                       <td style="border-left:1px solid #000000">1.4143</td>
                       <td style="border-left:1px solid #000000">1.4329</td>
                       <td style="border-left:1px solid #000000">1.4515</td>
                       <td style="border-left:1px solid #000000">1.5567</td>
                       <td style="border-left:1px solid #000000">1.6438</td>
                       <td style="border-left:1px solid #000000">1.7375</td>
                       <td style="border-left:1px solid #000000">1.8800</td>
                       <td style="border-left:1px solid #000000"></td>
				    </tr>
				
			</table>
		</div>
		<div id="zhu"> <!-- 注：表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率 -->注：&nbsp;表中三个月期限国债收益率是用于计算SDR利率的人民币代表性利率</div>
		<div id="font1">
			
				<div style="font-weight:bold; text-align: center;">
		               <!-- 国债及其他收益率曲线简介 -->国债及其他债券收益率曲线简介
		    	</div>
			
		      <div>
		         &nbsp; &nbsp; <!-- 国债及其他收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。
		                            其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债曲线样本包括同业存单和商业银行债券；AAA级中短期票据曲线样本包括AAA级超短期融资券、短期融资券和中期票据 -->
		                            国债及其他债券收益率曲线是由中央国债登记结算有限责任公司(www.chinabond.com.cn)编制提供的一组反映在岸人民币债券市场到期收益率走势的图表。其中，国债收益率曲线样本包括记账式附息国债和记账式贴现国债；AAA级商业银行普通债收益率曲线样本包括同业存单和商业银行债券；AAA级中短期票据收益率曲线样本包括AAA级超短期融资券、短期融资券和中期票据。
		      </div>
		      <div>
		        &nbsp; &nbsp; <!-- 中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、
		                       货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30 -->
		                           中债收益率曲线包括国债在内的各信用等级的到期、即期和远期收益曲线约1000余条，采用赫尔米特模型编制。曲线数据源包括银行间市场和交易所市场的做市商报价、货币经纪公司报价、成交价和结算价等。收益率曲线的样本点优先选取新发行且满足流动性要求的债券。中债收益率曲线每个工作日日终发布一次，发布时间为北京时间17:30。
		     </div>
		</div>
	</div>
	<input type="hidden" id="locale" value="cn_ZH">
</body>

<script type="text/javascript">

    Highcharts.setOptions({
        global: {
            useUTC: false
        },
    });
    var chart = null;
    var xData=new Array();
    var options = {
        chart : {
            exporting : {
                enabled : true //用来设置是否显示‘打印’,''导出''等功能按钮，不设置时默认为显示
            },
            renderTo : ''graph'',
            type: ''line'',
            marginBottom : 90,
            marginTop : 5,
            marginLeft : 50,
        },
        title : {
            text : ''''
        },
        xAxis : {
            labels:{
                style:{
                    fontSize:''10px'',
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            crosshair: {
                width: 1,
                color: ''#CC0000''
            },
            categories:xData,
            tickPositions: [0,10, 20,30, 50,70,110],
            tickWidth : 1,
            gridLineWidth : 1,
            lineWidth : 1,
            lineColor : ''black'',
            showFirstLabel : true,
            showLastLable : true,
            tickLength : 0,
        },

        yAxis : [ {
            labels : {
                format : ''{value:.,0f}'',
                padding : 50,
                x : -10,
                formatter : function(){
                    return this.value.toFixed(2);//这里是两位小数，你要几位小数就改成几
                },
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            title : {
                text : ''(%)'',
                align: ''high'',
                offset: 5,
                rotation:0,
                y: 85,
                x: -30,
                style:{
                    fontWeight:"normal",
                    fontSize: "10px",
                    fontFamily: "宋体",
                    color: "#333333",
                }
            },
            tickPixelInterval: 50,
            allowDecimals : true,//是否显示小数
            showFirstLabel : true,
            tickPosition : ''outside'',
            tickLength : 3,
            opposite : false,//设置y轴在对面显示
            lineWidth : 1,//设置y轴的线宽
            tickWidth : 1,
            tickColor : ''black'',
            lineColor : ''black'',
        } ],

        legend : {
            enabled : true,
            align: ''left'',
            layout: ''vertical'',
            floating: true,
            itemMarginTop: 3,
            x: 45,
            y: 10,
            itemStyle: {
                fontWeight:"normal",
                fontSize: "12px",
                fontFamily: "宋体",
                color: "#333333",
                cursor: "default",
            },
        },
        credits : {
            enabled : false //去掉higcharts.com
        },
        tooltip : {
            shared : false,
            split : true,
            animation : false,
            shape : ''square'',
            crosshairs : {
                width : 1,
                color : ''red''
            },
            distance : 3,//距离某个点的距离
            useHTML : true,
            borderWidth : 1,
            headerFormat : ''<small style="background-color:#DC143C">{point.key}</small><table border="5">'',
            pointFormat : ''<tr><td style="text-align: right,color:{point.color}">{point.y:.4f}%</td></tr>'',
            footerFormat : ''</table>'',
        },
        plotOptions : {
            series: {
                animation:false,
                states:{
                    hover:{
                        lineWidthPlus: 0
                    },
                },
                marker:{
                    symbol:''circle'',
                    enabled:true,
                    radius:0.1
                },
                connectNulls:true,//连接空点
            },
        },
        series : []
    }
    function query(){
        queryGjqxInfo();

        var workTime=document.getElementById("gzr").value;
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/query?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    var url = window.location.href;
    var locale=url.substring(url.indexOf("=") + 1, url.length).split(''&'');
	if ( locale !== ''en_US'') {
		locale = ''zh_CN''
	}

    function queryGjqxInfo(){
        var workTime = [document.getElementById("gzr").value];
		var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/queryGjqxInfo?&workTime="+workTime+"&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            dataType : "html",
            success : function(data) {
                $("#gjqxData").html(data);
            }
        });
    }



    function historyQuery(){
    	var localeValue = document.getElementById(''locale'').value;
		if(localeValue =="en_US" ){
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=''+localeValue,''newwindow'',''height=550,width=1145,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}else{
			window.open (''/cbweb-pbc-web/pbc/showHistory?locale=zh_CN'',''newwindow'',''height=550,width=980,top=0,left=0,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no,status=no'');
		}
    }



    function showInfo(msgInfo,title){
        alert(msgInfo);
    }

    var zero;
    var year;
    var month;
    var dataNullMsg;
    var LoadingDataFailedMsg;
    $(document).ready(function(){
        if(false){
            zero = "O/N";
            year = "Y";
            month = "M";
            dataNullMsg = "No matched yield curve is found,please trying other searching criteria.";
            LoadingDataFailedMsg = "Loading data failed";
        }else{
            zero = "0";
            year = "年";
            month = "月";
            dataNullMsg = "没有查询到曲线,请重新输入查询条件";
            LoadingDataFailedMsg = "取得数据失败";
        }

        pbcInit();
    });

    function pbcInit(){
        var locale = document.getElementById(''locale'').value;
        var url = "/cbweb-pbc-web/pbc/pbcInit?&locale="+locale;

        $.ajax({
            type : "post",
            url : url,
            cache : false,
            success : function(data) {
                createGraph(data);
            },
            error : function() {
                alert(LoadingDataFailedMsg);
                $(''#graph'').html("");
                return;
            }
        });
    }

    function createGraph(data){

        if(data == null || data.length == 0){
            alert(dataNullMsg);
            $(''#graph'').html("");
            return;
        }

        var tempData;

        options.series = new Array();
        for(var i = 0; i < data.length; i++){
            var yData = new Array();
            options.series[i]=new Object();

            tempData = data[i].seriesData;
            for(var j = 0; j < tempData.length; j++){

                var xValue = tempData[j][0];
                if(xValue == 0){
                    xData.push(zero);
                }else if(xValue > 0 && xValue < 1){
                    xData.push(xValue * 12 + month);
                }else if(xValue >= 1){
                    xData.push(xValue + year);
                }else{
                    xData.push(xValue);
                }

                var yValue;
                if(xValue < 0.25){
                    yValue = "";
                }else{
                    yValue = Number(tempData[j][1]);
                }
                if(xValue == 0.25 || xValue == 0.5 || xValue == 1 || xValue == 3
                    || xValue == 5 || xValue == 7 || xValue == 10 || xValue == 30){
                    yData.push({y:yValue,marker:{radius:2}});
                }else{
                    yData.push(yValue);
                }
                options.series[i].data = yData;
                options.series[i].name = data[i].ycDefName;
                options.series[i].color = colorArr[i];
                options.series[i].dataGrouping = {enabled : false};
                options.series[i].lineWidth = 1;
            }

        }

        chart = new Highcharts.Chart(options);
    }

</script>
</html>', 2, 'HTTP 200  ', NULL);

INSERT INTO vi_source_base (id, company_id, title, source_type, publisher, url, reliability, verify_status, summary, limitations) VALUES
(924, NULL, '10年国债到期收益率（中证口径）：Wind / 中证指数公司（2026 年历史数据）', '数据库取数', 'Wind / 中证指数公司', NULL, '三级·第三方数据', '待核验', '19 条历史数据（2026-08-25 至 2026-09-18）', '观察数据；水文不得直接外推全年电量；国债为中证口径，非中债，不自动改长期折现率'),
(925, NULL, '纸浆期货收盘价（Wind 活跃合约）：Wind 期货收盘价（活跃合约）（2021—2026 年历史数据）', '数据库取数', 'Wind EDB M0330982', NULL, '三级·第三方数据', '待核验', '1212 条历史数据（2021-10-21 至 2026-10-21）', '历史补数：Wind 期货收盘价（活跃合约）'),
(926, NULL, '港元兑人民币：腾讯外汇 K 线收盘价（2025—2026 年历史数据）', '数据库取数', NULL, 'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get?param=whHKDCNY,day', '三级·第三方数据', '待核验', '263 条历史数据（2025-10-20 至 2026-10-22）', '历史补数：腾讯外汇 K 线收盘价');

INSERT INTO vi_observation_base (id, obs_date, value, collected_at, metric_id, raw_capture_id, doc_id) VALUES
(1, '2026-08-25', 1.6796, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(2, '2026-08-26', 1.6867, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(3, '2026-08-27', 1.7009, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(4, '2026-08-28', 1.697, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(5, '2026-08-31', 1.6884, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(6, '2026-09-01', 1.6835, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(7, '2026-09-02', 1.6876, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(8, '2026-09-03', 1.6803, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(9, '2026-09-04', 1.68, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(10, '2026-09-07', 1.6809, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(11, '2026-09-08', 1.6811, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(12, '2026-09-09', 1.6812, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(13, '2026-09-10', 1.6813, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(14, '2026-09-11', 1.689, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(15, '2026-09-14', 1.6899, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(16, '2026-09-15', 1.6862, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(17, '2026-09-16', 1.6854, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(18, '2026-09-17', 1.6855, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(19, '2026-09-18', 1.6814, '2026-09-19T15:45:48.195416+08:00', 3, NULL, 924),
(41, '2026-09-18', 1.682, '2026-09-19T21:46:01+08:00', 2, 2, NULL),
(43, '2026-09-20', 1.6818, '2026-09-20T18:30:07+08:00', 2, 9, NULL),
(44, '2026-09-21', 1.6829, '2026-09-21T18:30:04+08:00', 2, 10, NULL),
(48, '2026-09-22', 1.6791, '2026-09-22T18:30:09+08:00', 2, 15, NULL),
(51, '2026-09-23', 1.6807, '2026-09-23T18:30:08+08:00', 2, 18, NULL),
(53, '2026-09-24', 1.6738, '2026-09-24T18:30:02+08:00', 2, 19, NULL),
(61, '2026-09-28', 1.679, '2026-09-28T18:30:02+08:00', 2, 31, NULL),
(64, '2026-09-29', 1.667, '2026-09-29T18:30:06+08:00', 2, 35, NULL),
(67, '2026-09-30', 1.6822, '2026-09-30T18:30:08+08:00', 2, 39, NULL),
(77, '2026-10-08', 1.6899, '2026-10-08T18:30:05+08:00', 2, 62, NULL),
(79, '2026-10-09', 1.6864, '2026-10-09T18:30:05+08:00', 2, 65, NULL),
(82, '2026-10-10', 1.6849, '2026-10-10T18:30:04+08:00', 2, 67, NULL),
(85, '2026-10-12', 1.6722, '2026-10-12T18:30:02+08:00', 2, 74, NULL),
(88, '2026-10-13', 1.6654, '2026-10-13T18:30:06+08:00', 2, 77, NULL),
(92, '2026-10-14', 1.6516, '2026-10-14T18:30:05+08:00', 2, 81, NULL),
(94, '2026-10-15', 1.6601, '2026-10-15T18:30:06+08:00', 2, 83, NULL),
(98, '2026-10-16', 1.648, '2026-10-16T18:30:05+08:00', 2, 86, NULL),
(102, '2026-10-19', 1.6497, '2026-10-19T18:30:08+08:00', 2, 96, NULL),
(105, '2026-10-20', 1.6354, '2026-10-20T18:30:07+08:00', 2, 98, NULL),
(109, '2026-10-21', 1.6412, '2026-10-21T18:30:05+08:00', 2, 100, NULL),
(356, '2021-10-21', 5306, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(357, '2021-10-22', 5242, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(358, '2021-10-25', 5112, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(359, '2021-10-26', 5100, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(360, '2021-10-27', 4878, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(361, '2021-10-28', 4758, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(362, '2021-10-29', 4894, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(363, '2021-11-01', 4916, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(364, '2021-11-02', 4922, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(365, '2021-11-03', 4990, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(366, '2021-11-04', 5000, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(367, '2021-11-05', 5032, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(368, '2021-11-08', 5058, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(369, '2021-11-09', 5042, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(370, '2021-11-10', 4908, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(371, '2021-11-11', 4944, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(372, '2021-11-12', 4868, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(373, '2021-11-15', 4886, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(374, '2021-11-16', 4866, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(375, '2021-11-17', 4904, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(376, '2021-11-18', 5046, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(377, '2021-11-19', 5092, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(378, '2021-11-22', 5164, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(379, '2021-11-23', 5190, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(380, '2021-11-24', 5228, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(381, '2021-11-25', 5266, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(382, '2021-11-26', 5392, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(383, '2021-11-29', 5562, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(384, '2021-11-30', 5626, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(385, '2021-12-01', 5980, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(386, '2021-12-02', 5998, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(387, '2021-12-03', 5976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(388, '2021-12-06', 5870, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(389, '2021-12-07', 5976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(390, '2021-12-08', 6104, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(391, '2021-12-09', 6042, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(392, '2021-12-10', 5736, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(393, '2021-12-13', 5646, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(394, '2021-12-14', 5644, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(395, '2021-12-15', 5626, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(396, '2021-12-16', 5640, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(397, '2021-12-17', 5414, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(398, '2021-12-20', 5456, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(399, '2021-12-21', 5460, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(400, '2021-12-22', 5548, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(401, '2021-12-23', 5780, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(402, '2021-12-24', 5834, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(403, '2021-12-27', 5786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(404, '2021-12-28', 5818, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(405, '2021-12-29', 5920, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(406, '2021-12-30', 6018, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(407, '2021-12-31', 6056, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(408, '2022-01-04', 6078, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(409, '2022-01-05', 6054, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(410, '2022-01-06', 6018, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(411, '2022-01-07', 6214, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(412, '2022-01-10', 6260, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(413, '2022-01-11', 6114, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(414, '2022-01-12', 6266, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(415, '2022-01-13', 6236, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(416, '2022-01-14', 6290, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(417, '2022-01-17', 6120, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(418, '2022-01-18', 6118, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(419, '2022-01-19', 6252, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(420, '2022-01-20', 6216, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(421, '2022-01-21', 6338, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(422, '2022-01-24', 6046, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(423, '2022-01-25', 6008, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(424, '2022-01-26', 6014, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(425, '2022-01-27', 5910, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(426, '2022-01-28', 6296, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(427, '2022-02-07', 6322, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(428, '2022-02-08', 6412, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(429, '2022-02-09', 6380, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(430, '2022-02-10', 6472, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(431, '2022-02-11', 6344, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(432, '2022-02-14', 6446, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(433, '2022-02-15', 6426, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(434, '2022-02-16', 6410, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(435, '2022-02-17', 6348, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(436, '2022-02-18', 6522, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(437, '2022-02-21', 6502, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(438, '2022-02-22', 6542, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(439, '2022-02-23', 6622, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(440, '2022-02-24', 6634, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(441, '2022-02-25', 6704, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(442, '2022-02-28', 6686, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(443, '2022-03-01', 6728, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(444, '2022-03-02', 6788, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(445, '2022-03-03', 6960, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(446, '2022-03-04', 6890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(447, '2022-03-07', 7134, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(448, '2022-03-08', 7224, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(449, '2022-03-09', 7438, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(450, '2022-03-10', 7272, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(451, '2022-03-11', 7222, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(452, '2022-03-14', 6908, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(453, '2022-03-15', 6712, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(454, '2022-03-16', 6854, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(455, '2022-03-17', 6770, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(456, '2022-03-18', 6826, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(457, '2022-03-21', 6734, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(458, '2022-03-22', 6988, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(459, '2022-03-23', 7124, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(460, '2022-03-24', 7024, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(461, '2022-03-25', 6782, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(462, '2022-03-28', 7016, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(463, '2022-03-29', 6962, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(464, '2022-03-30', 6848, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(465, '2022-03-31', 6770, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(466, '2022-04-01', 6776, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(467, '2022-04-06', 7014, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(468, '2022-04-07', 6776, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(469, '2022-04-08', 6890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(470, '2022-04-11', 7050, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(471, '2022-04-12', 7030, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(472, '2022-04-13', 6986, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(473, '2022-04-14', 7022, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(474, '2022-04-15', 7044, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(475, '2022-04-18', 7052, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(476, '2022-04-19', 7194, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(477, '2022-04-20', 7172, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(478, '2022-04-21', 7282, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(479, '2022-04-22', 7300, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(480, '2022-04-25', 6874, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(481, '2022-04-26', 6812, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(482, '2022-04-27', 7102, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(483, '2022-04-28', 7242, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(484, '2022-04-29', 7276, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(485, '2022-05-05', 7340, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(486, '2022-05-06', 7290, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(487, '2022-05-09', 7342, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(488, '2022-05-10', 7392, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(489, '2022-05-11', 7356, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(490, '2022-05-12', 7316, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(491, '2022-05-13', 7290, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(492, '2022-05-16', 7302, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(493, '2022-05-17', 7330, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(494, '2022-05-18', 7300, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(495, '2022-05-19', 7398, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(496, '2022-05-20', 7380, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(497, '2022-05-23', 7232, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(498, '2022-05-24', 7102, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(499, '2022-05-25', 7188, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(500, '2022-05-26', 7104, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(501, '2022-05-27', 7144, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(502, '2022-05-30', 7236, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(503, '2022-05-31', 6976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(504, '2022-06-01', 6994, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(505, '2022-06-02', 7248, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(506, '2022-06-06', 7232, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(507, '2022-06-07', 7232, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(508, '2022-06-08', 7180, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(509, '2022-06-09', 7036, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(510, '2022-06-10', 7152, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(511, '2022-06-13', 7002, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(512, '2022-06-14', 6990, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(513, '2022-06-15', 6898, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(514, '2022-06-16', 6946, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(515, '2022-06-17', 6938, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(516, '2022-06-20', 6900, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(517, '2022-06-21', 6856, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(518, '2022-06-22', 6646, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(519, '2022-06-23', 6610, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(520, '2022-06-24', 6434, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(521, '2022-06-27', 6762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(522, '2022-06-28', 6930, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(523, '2022-06-29', 6906, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(524, '2022-06-30', 6888, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(525, '2022-07-01', 6744, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(526, '2022-07-04', 6706, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(527, '2022-07-05', 6684, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(528, '2022-07-06', 6598, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(529, '2022-07-07', 6614, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(530, '2022-07-08', 6614, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(531, '2022-07-11', 6474, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(532, '2022-07-12', 6466, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(533, '2022-07-13', 6550, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(534, '2022-07-14', 6516, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(535, '2022-07-15', 6452, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(536, '2022-07-18', 6606, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(537, '2022-07-19', 6552, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(538, '2022-07-20', 6640, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(539, '2022-07-21', 6708, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(540, '2022-07-22', 6880, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(541, '2022-07-25', 6862, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(542, '2022-07-26', 6930, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(543, '2022-07-27', 6912, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(544, '2022-07-28', 7176, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(545, '2022-07-29', 7236, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(546, '2022-08-01', 7176, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(547, '2022-08-02', 7242, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(548, '2022-08-03', 7180, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(549, '2022-08-04', 7072, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(550, '2022-08-05', 7148, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(551, '2022-08-08', 7110, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(552, '2022-08-09', 7108, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(553, '2022-08-10', 7102, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(554, '2022-08-11', 7138, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(555, '2022-08-12', 6890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(556, '2022-08-15', 6914, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(557, '2022-08-16', 6926, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(558, '2022-08-17', 6264, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(559, '2022-08-18', 6250, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(560, '2022-08-19', 6284, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(561, '2022-08-22', 6526, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(562, '2022-08-23', 6580, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(563, '2022-08-24', 6550, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(564, '2022-08-25', 6652, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(565, '2022-08-26', 6648, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(566, '2022-08-29', 6566, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(567, '2022-08-30', 6562, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(568, '2022-08-31', 6652, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(569, '2022-09-01', 6592, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(570, '2022-09-02', 6610, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(571, '2022-09-05', 6652, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(572, '2022-09-06', 6780, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(573, '2022-09-07', 6772, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(574, '2022-09-08', 6796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(575, '2022-09-09', 6774, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(576, '2022-09-13', 6772, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(577, '2022-09-14', 6764, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(578, '2022-09-15', 6830, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(579, '2022-09-16', 6944, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(580, '2022-09-19', 6980, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(581, '2022-09-20', 6868, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(582, '2022-09-21', 6794, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(583, '2022-09-22', 6898, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(584, '2022-09-23', 6668, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(585, '2022-09-26', 6686, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(586, '2022-09-27', 6792, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(587, '2022-09-28', 6798, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(588, '2022-09-29', 6774, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(589, '2022-09-30', 6890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(590, '2022-10-10', 6898, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(591, '2022-10-11', 6806, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(592, '2022-10-12', 6896, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(593, '2022-10-13', 6752, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(594, '2022-10-14', 6684, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(595, '2022-10-17', 6702, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(596, '2022-10-18', 6744, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(597, '2022-10-19', 6822, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(598, '2022-10-20', 6774, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(599, '2022-10-21', 6772, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(600, '2022-10-24', 6846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(601, '2022-10-25', 6886, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(602, '2022-10-26', 6742, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(603, '2022-10-27', 6716, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(604, '2022-10-28', 6670, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(605, '2022-10-31', 6666, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(606, '2022-11-01', 6824, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(607, '2022-11-02', 6810, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(608, '2022-11-03', 6718, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(609, '2022-11-04', 6712, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(610, '2022-11-07', 6624, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(611, '2022-11-08', 6628, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(612, '2022-11-09', 6604, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(613, '2022-11-10', 6620, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(614, '2022-11-11', 6812, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(615, '2022-11-14', 6796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(616, '2022-11-15', 6810, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(617, '2022-11-16', 6858, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(618, '2022-11-17', 6872, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(619, '2022-11-18', 6920, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(620, '2022-11-21', 6898, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(621, '2022-11-22', 6964, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(622, '2022-11-23', 7080, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(623, '2022-11-24', 7136, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(624, '2022-11-25', 7100, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(625, '2022-11-28', 6984, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(626, '2022-11-29', 6960, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(627, '2022-11-30', 6982, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(628, '2022-12-01', 7020, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(629, '2022-12-02', 7200, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(630, '2022-12-05', 7272, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(631, '2022-12-06', 7236, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(632, '2022-12-07', 7216, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(633, '2022-12-08', 7240, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(634, '2022-12-09', 7256, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(635, '2022-12-12', 7390, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(636, '2022-12-13', 7298, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(637, '2022-12-14', 7162, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(638, '2022-12-15', 7176, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(639, '2022-12-16', 6940, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(640, '2022-12-19', 6502, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(641, '2022-12-20', 6506, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(642, '2022-12-21', 6564, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(643, '2022-12-22', 6540, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(644, '2022-12-23', 6470, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(645, '2022-12-26', 6760, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(646, '2022-12-27', 6754, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(647, '2022-12-28', 6636, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(648, '2022-12-29', 6636, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(649, '2022-12-30', 6726, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(650, '2023-01-03', 6636, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(651, '2023-01-04', 6636, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(652, '2023-01-05', 6596, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(653, '2023-01-06', 6670, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(654, '2023-01-09', 6424, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(655, '2023-01-10', 6352, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(656, '2023-01-11', 6326, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(657, '2023-01-12', 6362, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(658, '2023-01-13', 6472, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(659, '2023-01-16', 6486, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(660, '2023-01-17', 6466, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(661, '2023-01-18', 6614, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(662, '2023-01-19', 6610, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(663, '2023-01-20', 6794, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(664, '2023-01-30', 6786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(665, '2023-01-31', 6874, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(666, '2023-02-01', 6904, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(667, '2023-02-02', 6788, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(668, '2023-02-03', 6862, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(669, '2023-02-06', 6872, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(670, '2023-02-07', 6810, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(671, '2023-02-08', 6754, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(672, '2023-02-09', 6756, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(673, '2023-02-10', 6682, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(674, '2023-02-13', 6638, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(675, '2023-02-14', 6570, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(676, '2023-02-15', 6660, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(677, '2023-02-16', 6598, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(678, '2023-02-17', 6576, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(679, '2023-02-20', 6606, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(680, '2023-02-21', 6666, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(681, '2023-02-22', 6662, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(682, '2023-02-23', 6512, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(683, '2023-02-24', 6480, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(684, '2023-02-27', 6476, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(685, '2023-02-28', 6522, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(686, '2023-03-01', 6508, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(687, '2023-03-02', 6434, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(688, '2023-03-03', 6370, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(689, '2023-03-06', 6430, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(690, '2023-03-07', 6418, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(691, '2023-03-08', 6386, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(692, '2023-03-09', 6240, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(693, '2023-03-10', 6120, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(694, '2023-03-13', 6158, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(695, '2023-03-14', 6134, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(696, '2023-03-15', 6126, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(697, '2023-03-16', 5934, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(698, '2023-03-17', 5878, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(699, '2023-03-20', 5766, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(700, '2023-03-21', 5626, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(701, '2023-03-22', 5668, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(702, '2023-03-23', 5674, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(703, '2023-03-24', 5830, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(704, '2023-03-27', 5868, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(705, '2023-03-28', 5804, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(706, '2023-03-29', 5756, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(707, '2023-03-30', 5696, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(708, '2023-03-31', 5580, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(709, '2023-04-03', 5766, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(710, '2023-04-04', 5666, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(711, '2023-04-06', 5564, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(712, '2023-04-07', 5636, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(713, '2023-04-10', 5574, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(714, '2023-04-11', 5486, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(715, '2023-04-12', 5470, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(716, '2023-04-13', 5368, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(717, '2023-04-14', 5422, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(718, '2023-04-17', 5468, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(719, '2023-04-18', 5478, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(720, '2023-04-19', 5436, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(721, '2023-04-20', 5342, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(722, '2023-04-21', 5208, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(723, '2023-04-24', 5246, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(724, '2023-04-25', 5240, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(725, '2023-04-26', 5178, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(726, '2023-04-27', 5096, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(727, '2023-04-28', 5058, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(728, '2023-05-04', 5100, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(729, '2023-05-05', 5164, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(730, '2023-05-08', 5170, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(731, '2023-05-09', 5172, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(732, '2023-05-10', 5194, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(733, '2023-05-11', 5096, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(734, '2023-05-12', 5230, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(735, '2023-05-15', 5218, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(736, '2023-05-16', 5272, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(737, '2023-05-17', 5272, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(738, '2023-05-18', 5288, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(739, '2023-05-19', 5232, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(740, '2023-05-22', 5124, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(741, '2023-05-23', 5282, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(742, '2023-05-24', 5246, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(743, '2023-05-25', 5142, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(744, '2023-05-26', 5168, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(745, '2023-05-29', 5202, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(746, '2023-05-30', 5140, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(747, '2023-05-31', 5126, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(748, '2023-06-01', 5188, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(749, '2023-06-02', 5170, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(750, '2023-06-05', 5124, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(751, '2023-06-06', 5102, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(752, '2023-06-07', 4974, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(753, '2023-06-08', 4998, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(754, '2023-06-09', 5134, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(755, '2023-06-12', 5176, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(756, '2023-06-13', 5132, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(757, '2023-06-14', 5168, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(758, '2023-06-15', 5194, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(759, '2023-06-16', 5210, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(760, '2023-06-19', 5196, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(761, '2023-06-20', 5140, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(762, '2023-06-21', 5158, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(763, '2023-06-26', 5070, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(764, '2023-06-27', 5142, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(765, '2023-06-28', 5120, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(766, '2023-06-29', 5180, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(767, '2023-06-30', 5184, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(768, '2023-07-03', 5262, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(769, '2023-07-04', 5382, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(770, '2023-07-05', 5384, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(771, '2023-07-06', 5334, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(772, '2023-07-07', 5290, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(773, '2023-07-10', 5344, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(774, '2023-07-11', 5354, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(775, '2023-07-12', 5382, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(776, '2023-07-13', 5338, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(777, '2023-07-14', 5360, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(778, '2023-07-17', 5194, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(779, '2023-07-18', 5214, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(780, '2023-07-19', 5256, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(781, '2023-07-20', 5284, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(782, '2023-07-21', 5234, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(783, '2023-07-24', 5264, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(784, '2023-07-25', 5342, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(785, '2023-07-26', 5396, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(786, '2023-07-27', 5504, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(787, '2023-07-28', 5544, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(788, '2023-07-31', 5496, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(789, '2023-08-01', 5490, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(790, '2023-08-02', 5512, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(791, '2023-08-03', 5344, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(792, '2023-08-04', 5330, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(793, '2023-08-07', 5352, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(794, '2023-08-08', 5338, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(795, '2023-08-09', 5346, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(796, '2023-08-10', 5334, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(797, '2023-08-11', 5308, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(798, '2023-08-14', 5294, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(799, '2023-08-15', 5506, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(800, '2023-08-16', 5386, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(801, '2023-08-17', 5416, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(802, '2023-08-18', 5434, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(803, '2023-08-21', 5474, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(804, '2023-08-22', 5530, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(805, '2023-08-23', 5600, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(806, '2023-08-24', 5604, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(807, '2023-08-25', 5638, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(808, '2023-08-28', 5594, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(809, '2023-08-29', 5508, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(810, '2023-08-30', 5610, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(811, '2023-08-31', 5610, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(812, '2023-09-01', 5814, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(813, '2023-09-04', 5796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(814, '2023-09-05', 5836, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(815, '2023-09-06', 5842, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(816, '2023-09-07', 5712, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(817, '2023-09-08', 5646, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(818, '2023-09-11', 5742, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(819, '2023-09-12', 5776, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(820, '2023-09-13', 5714, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(821, '2023-09-14', 5748, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(822, '2023-09-15', 5846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(823, '2023-09-18', 5954, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(824, '2023-09-19', 5984, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(825, '2023-09-20', 6084, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(826, '2023-09-21', 6102, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(827, '2023-09-22', 6080, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(828, '2023-09-25', 6056, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(829, '2023-09-26', 6126, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(830, '2023-09-27', 6190, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(831, '2023-09-28', 6282, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(832, '2023-10-09', 6316, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(833, '2023-10-10', 6228, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(834, '2023-10-11', 6276, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(835, '2023-10-12', 6350, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(836, '2023-10-13', 6282, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(837, '2023-10-16', 6324, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(838, '2023-10-17', 6234, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(839, '2023-10-18', 6162, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(840, '2023-10-19', 6200, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(841, '2023-10-20', 6114, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(842, '2023-10-23', 6068, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(843, '2023-10-24', 6090, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(844, '2023-10-25', 6086, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(845, '2023-10-26', 5974, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(846, '2023-10-27', 5928, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(847, '2023-10-30', 5986, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(848, '2023-10-31', 6024, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(849, '2023-11-01', 5996, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(850, '2023-11-02', 5976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(851, '2023-11-03', 6116, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(852, '2023-11-06', 6180, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(853, '2023-11-07', 6132, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(854, '2023-11-08', 6182, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(855, '2023-11-09', 5906, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(856, '2023-11-10', 5918, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(857, '2023-11-13', 5982, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(858, '2023-11-14', 5958, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(859, '2023-11-15', 5992, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(860, '2023-11-16', 6100, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(861, '2023-11-17', 6044, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(862, '2023-11-20', 5978, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(863, '2023-11-21', 5950, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(864, '2023-11-22', 5792, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(865, '2023-11-23', 5774, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(866, '2023-11-24', 5836, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(867, '2023-11-27', 5844, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(868, '2023-11-28', 5818, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(869, '2023-11-29', 5602, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(870, '2023-11-30', 5650, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(871, '2023-12-01', 5478, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(872, '2023-12-04', 5522, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(873, '2023-12-05', 5416, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(874, '2023-12-06', 5438, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(875, '2023-12-07', 5512, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(876, '2023-12-08', 5736, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(877, '2023-12-11', 5724, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(878, '2023-12-12', 5668, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(879, '2023-12-13', 5606, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(880, '2023-12-14', 5642, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(881, '2023-12-15', 5672, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(882, '2023-12-18', 5776, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(883, '2023-12-19', 5712, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(884, '2023-12-20', 5758, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(885, '2023-12-21', 5800, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(886, '2023-12-22', 5804, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(887, '2023-12-25', 5798, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(888, '2023-12-26', 5724, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(889, '2023-12-27', 5796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(890, '2023-12-28', 5774, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(891, '2023-12-29', 5640, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(892, '2024-01-02', 5854, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(893, '2024-01-03', 5948, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(894, '2024-01-04', 5882, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(895, '2024-01-05', 5872, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(896, '2024-01-08', 5810, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(897, '2024-01-09', 5742, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(898, '2024-01-10', 5680, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(899, '2024-01-11', 5716, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(900, '2024-01-12', 5722, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(901, '2024-01-15', 5730, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(902, '2024-01-16', 5732, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(903, '2024-01-17', 5702, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(904, '2024-01-18', 5742, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(905, '2024-01-19', 5720, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(906, '2024-01-22', 5650, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(907, '2024-01-23', 5690, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(908, '2024-01-24', 5778, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(909, '2024-01-25', 5772, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(910, '2024-01-26', 5734, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(911, '2024-01-29', 5686, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(912, '2024-01-30', 5702, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(913, '2024-01-31', 5670, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(914, '2024-02-01', 5710, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(915, '2024-02-02', 5612, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(916, '2024-02-05', 5646, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(917, '2024-02-06', 5564, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(918, '2024-02-07', 5564, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(919, '2024-02-08', 5570, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(920, '2024-02-19', 5714, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(921, '2024-02-20', 5746, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(922, '2024-02-21', 5762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(923, '2024-02-22', 5762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(924, '2024-02-23', 5796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(925, '2024-02-26', 5820, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(926, '2024-02-27', 5860, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(927, '2024-02-28', 5868, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(928, '2024-02-29', 5884, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(929, '2024-03-01', 5854, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(930, '2024-03-04', 5832, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(931, '2024-03-05', 5808, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(932, '2024-03-06', 5814, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(933, '2024-03-07', 5936, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(934, '2024-03-08', 5970, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(935, '2024-03-11', 5990, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(936, '2024-03-12', 6018, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(937, '2024-03-13', 6054, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(938, '2024-03-14', 6036, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(939, '2024-03-15', 6044, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(940, '2024-03-18', 6012, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(941, '2024-03-19', 6142, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(942, '2024-03-20', 6194, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(943, '2024-03-21', 6158, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(944, '2024-03-22', 6184, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(945, '2024-03-25', 6118, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(946, '2024-03-26', 6058, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(947, '2024-03-27', 6090, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(948, '2024-03-28', 6118, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(949, '2024-03-29', 6138, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(950, '2024-04-01', 6166, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(951, '2024-04-02', 6108, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(952, '2024-04-03', 6042, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(953, '2024-04-08', 6074, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(954, '2024-04-09', 6122, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(955, '2024-04-10', 6132, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(956, '2024-04-11', 6300, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(957, '2024-04-12', 6430, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(958, '2024-04-15', 6396, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(959, '2024-04-16', 6346, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(960, '2024-04-17', 6342, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(961, '2024-04-18', 6224, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(962, '2024-04-19', 6290, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(963, '2024-04-22', 6290, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(964, '2024-04-23', 6292, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(965, '2024-04-24', 6364, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(966, '2024-04-25', 6332, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(967, '2024-04-26', 6330, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(968, '2024-04-29', 6394, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(969, '2024-04-30', 6372, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(970, '2024-05-06', 6418, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(971, '2024-05-07', 6348, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(972, '2024-05-08', 6328, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(973, '2024-05-09', 6278, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(974, '2024-05-10', 6234, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(975, '2024-05-13', 6268, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(976, '2024-05-14', 6272, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(977, '2024-05-15', 6236, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(978, '2024-05-16', 6380, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(979, '2024-05-17', 6382, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(980, '2024-05-20', 6386, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(981, '2024-05-21', 6412, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(982, '2024-05-22', 6456, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(983, '2024-05-23', 6284, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(984, '2024-05-24', 6284, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(985, '2024-05-27', 6286, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(986, '2024-05-28', 6296, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(987, '2024-05-29', 6286, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(988, '2024-05-30', 6270, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(989, '2024-05-31', 6204, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(990, '2024-06-03', 6052, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(991, '2024-06-04', 6030, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(992, '2024-06-05', 6064, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(993, '2024-06-06', 6084, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(994, '2024-06-07', 6074, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(995, '2024-06-11', 6060, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(996, '2024-06-12', 6062, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(997, '2024-06-13', 5970, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(998, '2024-06-14', 5978, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(999, '2024-06-17', 5996, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1000, '2024-06-18', 5928, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1001, '2024-06-19', 5906, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1002, '2024-06-20', 5936, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1003, '2024-06-21', 5886, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1004, '2024-06-24', 5888, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1005, '2024-06-25', 5956, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1006, '2024-06-26', 6016, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1007, '2024-06-27', 5960, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1008, '2024-06-28', 5970, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1009, '2024-07-01', 5904, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1010, '2024-07-02', 5938, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1011, '2024-07-03', 6012, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1012, '2024-07-04', 5864, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1013, '2024-07-05', 5790, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1014, '2024-07-08', 5764, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1015, '2024-07-09', 5740, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1016, '2024-07-10', 5678, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1017, '2024-07-11', 5730, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1018, '2024-07-12', 5748, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1019, '2024-07-15', 5736, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1020, '2024-07-16', 5720, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1021, '2024-07-17', 5686, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1022, '2024-07-18', 5758, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1023, '2024-07-19', 5752, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1024, '2024-07-22', 5682, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1025, '2024-07-23', 5640, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1026, '2024-07-24', 5720, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1027, '2024-07-25', 5618, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1028, '2024-07-26', 5666, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1029, '2024-07-29', 5716, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1030, '2024-07-30', 5662, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1031, '2024-07-31', 5726, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1032, '2024-08-01', 5736, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1033, '2024-08-02', 5782, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1034, '2024-08-05', 5666, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1035, '2024-08-06', 5660, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1036, '2024-08-07', 5676, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1037, '2024-08-08', 5584, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1038, '2024-08-09', 5716, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1039, '2024-08-12', 5692, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1040, '2024-08-13', 5660, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1041, '2024-08-14', 5604, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1042, '2024-08-15', 5630, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1043, '2024-08-16', 5658, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1044, '2024-08-19', 5684, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1045, '2024-08-20', 5698, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1046, '2024-08-21', 5906, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1047, '2024-08-22', 5910, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1048, '2024-08-23', 5858, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1049, '2024-08-26', 5942, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1050, '2024-08-27', 5976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1051, '2024-08-28', 5980, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1052, '2024-08-29', 6036, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1053, '2024-08-30', 6038, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1054, '2024-09-02', 5986, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1055, '2024-09-03', 6078, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1056, '2024-09-04', 5802, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1057, '2024-09-05', 5838, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1058, '2024-09-06', 5816, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1059, '2024-09-09', 5786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1060, '2024-09-10', 5746, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1061, '2024-09-11', 5672, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1062, '2024-09-12', 5658, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1063, '2024-09-13', 5666, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1064, '2024-09-18', 5642, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1065, '2024-09-19', 5738, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1066, '2024-09-20', 5800, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1067, '2024-09-23', 5762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1068, '2024-09-24', 5798, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1069, '2024-09-25', 5808, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1070, '2024-09-26', 5816, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1071, '2024-09-27', 5880, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1072, '2024-09-30', 5912, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1073, '2024-10-08', 5784, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1074, '2024-10-09', 5792, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1075, '2024-10-10', 5756, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1076, '2024-10-11', 5906, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1077, '2024-10-14', 5920, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1078, '2024-10-15', 5874, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1079, '2024-10-16', 5744, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1080, '2024-10-17', 5762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1081, '2024-10-18', 5858, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1082, '2024-10-21', 5890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1083, '2024-10-22', 5898, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1084, '2024-10-23', 5876, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1085, '2024-10-24', 5866, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1086, '2024-10-25', 5788, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1087, '2024-10-28', 5818, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1088, '2024-10-29', 5786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1089, '2024-10-30', 5852, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1090, '2024-10-31', 5844, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1091, '2024-11-01', 5788, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1092, '2024-11-04', 5796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1093, '2024-11-05', 5774, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1094, '2024-11-06', 5758, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1095, '2024-11-07', 5852, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1096, '2024-11-08', 5856, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1097, '2024-11-11', 5766, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1098, '2024-11-12', 5766, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1099, '2024-11-13', 5866, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1100, '2024-11-14', 5936, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1101, '2024-11-15', 5880, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1102, '2024-11-18', 5918, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1103, '2024-11-19', 5920, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1104, '2024-11-20', 5926, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1105, '2024-11-21', 5956, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1106, '2024-11-22', 5922, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1107, '2024-11-25', 5840, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1108, '2024-11-26', 5828, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1109, '2024-11-27', 5834, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1110, '2024-11-28', 5822, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1111, '2024-11-29', 5844, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1112, '2024-12-02', 5890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1113, '2024-12-03', 5888, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1114, '2024-12-04', 5830, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1115, '2024-12-05', 5786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1116, '2024-12-06', 5866, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1117, '2024-12-09', 5810, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1118, '2024-12-10', 5826, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1119, '2024-12-11', 5830, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1120, '2024-12-12', 5804, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1121, '2024-12-13', 5762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1122, '2024-12-16', 5780, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1123, '2024-12-17', 5814, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1124, '2024-12-18', 5804, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1125, '2024-12-19', 5768, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1126, '2024-12-20', 5782, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1127, '2024-12-23', 5796, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1128, '2024-12-24', 5912, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1129, '2024-12-25', 5920, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1130, '2024-12-26', 5922, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1131, '2024-12-27', 5964, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1132, '2024-12-30', 5926, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1133, '2024-12-31', 5944, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1134, '2025-01-02', 6046, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1135, '2025-01-03', 6026, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1136, '2025-01-06', 6070, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1137, '2025-01-07', 5958, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1138, '2025-01-08', 5944, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1139, '2025-01-09', 5876, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1140, '2025-01-10', 5852, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1141, '2025-01-13', 5976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1142, '2025-01-14', 6010, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1143, '2025-01-15', 5996, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1144, '2025-01-16', 6000, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1145, '2025-01-17', 5998, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1146, '2025-01-20', 5992, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1147, '2025-01-21', 5986, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1148, '2025-01-22', 6102, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1149, '2025-01-23', 6132, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1150, '2025-01-24', 6114, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1151, '2025-01-27', 6122, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1152, '2025-02-05', 6194, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1153, '2025-02-06', 6168, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1154, '2025-02-07', 6156, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1155, '2025-02-10', 6128, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1156, '2025-02-11', 6116, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1157, '2025-02-12', 6122, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1158, '2025-02-13', 6108, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1159, '2025-02-14', 6098, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1160, '2025-02-17', 6088, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1161, '2025-02-18', 6084, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1162, '2025-02-19', 6034, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1163, '2025-02-20', 6034, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1164, '2025-02-21', 6034, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1165, '2025-02-24', 6024, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1166, '2025-02-25', 5968, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1167, '2025-02-26', 5976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1168, '2025-02-27', 5986, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1169, '2025-02-28', 5962, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1170, '2025-03-03', 5944, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1171, '2025-03-04', 5888, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1172, '2025-03-05', 5852, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1173, '2025-03-06', 5858, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1174, '2025-03-07', 5864, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1175, '2025-03-10', 5868, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1176, '2025-03-11', 5896, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1177, '2025-03-12', 5906, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1178, '2025-03-13', 5874, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1179, '2025-03-14', 5918, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1180, '2025-03-17', 5890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1181, '2025-03-18', 5830, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1182, '2025-03-19', 5836, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1183, '2025-03-20', 5890, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1184, '2025-03-21', 5752, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1185, '2025-03-24', 5772, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1186, '2025-03-25', 5754, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1187, '2025-03-26', 5722, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1188, '2025-03-27', 5714, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1189, '2025-03-28', 5724, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1190, '2025-03-31', 5644, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1191, '2025-04-01', 5638, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1192, '2025-04-02', 5672, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1193, '2025-04-03', 5552, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1194, '2025-04-07', 5360, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1195, '2025-04-08', 5442, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1196, '2025-04-09', 5202, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1197, '2025-04-10', 5350, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1198, '2025-04-11', 5408, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1199, '2025-04-14', 5390, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1200, '2025-04-15', 5416, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1201, '2025-04-16', 5356, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1202, '2025-04-17', 5332, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1203, '2025-04-18', 5362, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1204, '2025-04-21', 5396, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1205, '2025-04-22', 5350, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1206, '2025-04-23', 5402, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1207, '2025-04-24', 5388, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1208, '2025-04-25', 5376, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1209, '2025-04-28', 5344, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1210, '2025-04-29', 5178, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1211, '2025-04-30', 5120, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1212, '2025-05-06', 5036, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1213, '2025-05-07', 5138, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1214, '2025-05-08', 5148, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1215, '2025-05-09', 5164, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1216, '2025-05-12', 5256, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1217, '2025-05-13', 5276, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1218, '2025-05-14', 5378, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1219, '2025-05-15', 5386, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1220, '2025-05-16', 5356, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1221, '2025-05-19', 5390, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1222, '2025-05-20', 5410, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1223, '2025-05-21', 5420, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1224, '2025-05-22', 5426, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1225, '2025-05-23', 5464, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1226, '2025-05-26', 5402, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1227, '2025-05-27', 5274, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1228, '2025-05-28', 5326, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1229, '2025-05-29', 5492, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1230, '2025-05-30', 5414, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1231, '2025-06-03', 5304, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1232, '2025-06-04', 5298, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1233, '2025-06-05', 5280, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1234, '2025-06-06', 5280, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1235, '2025-06-09', 5394, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1236, '2025-06-10', 5376, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1237, '2025-06-11', 5346, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1238, '2025-06-12', 5268, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1239, '2025-06-13', 5242, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1240, '2025-06-16', 5274, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1241, '2025-06-17', 5220, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1242, '2025-06-18', 5240, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1243, '2025-06-19', 5254, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1244, '2025-06-20', 5120, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1245, '2025-06-23', 5278, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1246, '2025-06-24', 5136, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1247, '2025-06-25', 5070, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1248, '2025-06-26', 5066, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1249, '2025-06-27', 5096, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1250, '2025-06-30', 5064, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1251, '2025-07-01', 5026, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1252, '2025-07-02', 5072, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1253, '2025-07-03', 5094, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1254, '2025-07-04', 5068, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1255, '2025-07-07', 5074, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1256, '2025-07-08', 5086, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1257, '2025-07-09', 5106, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1258, '2025-07-10', 5196, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1259, '2025-07-11', 5234, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1260, '2025-07-14', 5244, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1261, '2025-07-15', 5262, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1262, '2025-07-16', 5242, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1263, '2025-07-17', 5264, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1264, '2025-07-18', 5292, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1265, '2025-07-21', 5334, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1266, '2025-07-22', 5368, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1267, '2025-07-23', 5414, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1268, '2025-07-24', 5456, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1269, '2025-07-25', 5520, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1270, '2025-07-28', 5360, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1271, '2025-07-29', 5374, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1272, '2025-07-30', 5326, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1273, '2025-07-31', 5232, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1274, '2025-08-01', 5186, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1275, '2025-08-04', 5168, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1276, '2025-08-05', 5160, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1277, '2025-08-06', 5170, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1278, '2025-08-07', 5186, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1279, '2025-08-08', 5162, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1280, '2025-08-11', 5246, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1281, '2025-08-12', 5264, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1282, '2025-08-13', 5302, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1283, '2025-08-14', 5318, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1284, '2025-08-15', 5306, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1285, '2025-08-18', 5252, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1286, '2025-08-19', 5178, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1287, '2025-08-20', 5136, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1288, '2025-08-21', 5130, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1289, '2025-08-22', 5108, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1290, '2025-08-25', 5136, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1291, '2025-08-26', 5070, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1292, '2025-08-27', 5010, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1293, '2025-08-28', 5002, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1294, '2025-08-29', 5018, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1295, '2025-09-01', 5040, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1296, '2025-09-02', 5042, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1297, '2025-09-03', 5050, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1298, '2025-09-04', 5052, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1299, '2025-09-05', 5062, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1300, '2025-09-08', 5026, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1301, '2025-09-09', 4970, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1302, '2025-09-10', 4996, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1303, '2025-09-11', 5016, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1304, '2025-09-12', 4990, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1305, '2025-09-15', 5056, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1306, '2025-09-16', 5068, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1307, '2025-09-17', 5042, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1308, '2025-09-18', 5014, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1309, '2025-09-19', 5018, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1310, '2025-09-22', 5008, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1311, '2025-09-23', 5008, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1312, '2025-09-24', 5044, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1313, '2025-09-25', 5060, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1314, '2025-09-26', 5016, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1315, '2025-09-29', 4878, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1316, '2025-09-30', 4834, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1317, '2025-10-09', 4804, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1318, '2025-10-10', 4788, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1319, '2025-10-13', 4842, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1320, '2025-10-14', 4846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1321, '2025-10-15', 4856, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1322, '2025-10-16', 4856, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1323, '2025-10-17', 5122, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1324, '2025-10-20', 5156, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1325, '2025-10-21', 5170, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1326, '2025-10-22', 5220, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1327, '2025-10-23', 5250, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1328, '2025-10-24', 5240, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1329, '2025-10-27', 5258, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1330, '2025-10-28', 5226, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1331, '2025-10-29', 5242, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1332, '2025-10-30', 5224, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1333, '2025-10-31', 5212, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1334, '2025-11-03', 5306, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1335, '2025-11-04', 5288, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1336, '2025-11-05', 5360, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1337, '2025-11-06', 5368, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1338, '2025-11-07', 5394, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1339, '2025-11-10', 5468, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1340, '2025-11-11', 5484, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1341, '2025-11-12', 5482, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1342, '2025-11-13', 5534, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1343, '2025-11-14', 5480, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1344, '2025-11-17', 5474, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1345, '2025-11-18', 5408, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1346, '2025-11-19', 5396, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1347, '2025-11-20', 5298, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1348, '2025-11-21', 5228, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1349, '2025-11-24', 5220, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1350, '2025-11-25', 5212, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1351, '2025-11-26', 5208, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1352, '2025-11-27', 5184, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1353, '2025-11-28', 5198, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1354, '2025-12-01', 5190, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1355, '2025-12-02', 5328, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1356, '2025-12-03', 5458, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1357, '2025-12-04', 5496, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1358, '2025-12-05', 5450, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1359, '2025-12-08', 5392, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1360, '2025-12-09', 5386, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1361, '2025-12-10', 5436, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1362, '2025-12-11', 5586, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1363, '2025-12-12', 5534, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1364, '2025-12-15', 5572, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1365, '2025-12-16', 5468, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1366, '2025-12-17', 5506, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1367, '2025-12-18', 5500, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1368, '2025-12-19', 5506, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1369, '2025-12-22', 5622, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1370, '2025-12-23', 5620, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1371, '2025-12-24', 5620, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1372, '2025-12-25', 5604, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1373, '2025-12-26', 5630, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1374, '2025-12-29', 5510, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1375, '2025-12-30', 5568, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1376, '2025-12-31', 5532, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1377, '2026-01-05', 5530, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1378, '2026-01-06', 5612, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1379, '2026-01-07', 5596, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1380, '2026-01-08', 5504, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1381, '2026-01-09', 5550, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1382, '2026-01-12', 5490, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1383, '2026-01-13', 5492, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1384, '2026-01-14', 5494, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1385, '2026-01-15', 5436, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1386, '2026-01-16', 5362, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1387, '2026-01-19', 5362, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1388, '2026-01-20', 5376, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1389, '2026-01-21', 5360, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1390, '2026-01-22', 5380, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1391, '2026-01-23', 5398, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1392, '2026-01-26', 5374, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1393, '2026-01-27', 5342, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1394, '2026-01-28', 5374, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1395, '2026-01-29', 5388, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1396, '2026-01-30', 5300, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1397, '2026-02-02', 5266, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1398, '2026-02-03', 5276, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1399, '2026-02-04', 5324, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1400, '2026-02-05', 5254, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1401, '2026-02-06', 5234, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1402, '2026-02-09', 5200, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1403, '2026-02-10', 5202, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1404, '2026-02-11', 5236, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1405, '2026-02-12', 5238, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1406, '2026-02-13', 5260, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1407, '2026-02-24', 5340, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1408, '2026-02-25', 5348, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1409, '2026-02-26', 5312, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1410, '2026-02-27', 5246, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1411, '2026-03-02', 5252, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1412, '2026-03-03', 5220, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1413, '2026-03-04', 5246, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1414, '2026-03-05', 5250, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1415, '2026-03-06', 5322, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1416, '2026-03-09', 5300, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1417, '2026-03-10', 5244, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1418, '2026-03-11', 5260, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1419, '2026-03-12', 5252, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1420, '2026-03-13', 5272, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1421, '2026-03-16', 5232, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1422, '2026-03-17', 5088, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1423, '2026-03-18', 5040, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1424, '2026-03-19', 5104, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1425, '2026-03-20', 5164, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1426, '2026-03-23', 5188, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1427, '2026-03-24', 5210, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1428, '2026-03-25', 5224, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1429, '2026-03-26', 5156, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1430, '2026-03-27', 5202, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1431, '2026-03-30', 5182, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1432, '2026-03-31', 5124, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1433, '2026-04-01', 5072, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1434, '2026-04-02', 5076, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1435, '2026-04-03', 5096, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1436, '2026-04-07', 5032, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1437, '2026-04-08', 5058, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1438, '2026-04-09', 4996, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1439, '2026-04-10', 5010, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1440, '2026-04-13', 4986, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1441, '2026-04-14', 4972, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1442, '2026-04-15', 4932, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1443, '2026-04-16', 4988, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1444, '2026-04-17', 5022, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1445, '2026-04-20', 5152, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1446, '2026-04-21', 5134, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1447, '2026-04-22', 5150, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1448, '2026-04-23', 5090, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1449, '2026-04-24', 5060, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1450, '2026-04-27', 5082, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1451, '2026-04-28', 5040, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1452, '2026-04-29', 5062, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1453, '2026-04-30', 5072, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1454, '2026-05-06', 5104, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1455, '2026-05-07', 5064, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1456, '2026-05-08', 5066, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1457, '2026-05-11', 5134, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1458, '2026-05-12', 5138, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1459, '2026-05-13', 5166, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1460, '2026-05-14', 5110, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1461, '2026-05-15', 5066, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1462, '2026-05-18', 5052, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1463, '2026-05-19', 5060, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1464, '2026-05-20', 4996, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1465, '2026-05-21', 4932, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1466, '2026-05-22', 4912, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1467, '2026-05-25', 4976, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1468, '2026-05-26', 4982, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1469, '2026-05-27', 4968, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1470, '2026-05-28', 4964, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1471, '2026-05-29', 4922, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1472, '2026-06-01', 4886, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1473, '2026-06-02', 4860, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1474, '2026-06-03', 4860, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1475, '2026-06-04', 4812, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1476, '2026-06-05', 4846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1477, '2026-06-08', 4844, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1478, '2026-06-09', 4878, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1479, '2026-06-10', 4868, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1480, '2026-06-11', 4900, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1481, '2026-06-12', 4896, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1482, '2026-06-15', 4912, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1483, '2026-06-16', 4940, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1484, '2026-06-17', 4938, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1485, '2026-06-18', 4866, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1486, '2026-06-22', 4818, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1487, '2026-06-23', 4726, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1488, '2026-06-24', 4690, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1489, '2026-06-25', 4644, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1490, '2026-06-26', 4616, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1491, '2026-06-29', 4690, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1492, '2026-06-30', 4690, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1493, '2026-07-01', 4740, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1494, '2026-07-02', 4736, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1495, '2026-07-03', 4752, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1496, '2026-07-06', 4694, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1497, '2026-07-07', 4688, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1498, '2026-07-08', 4658, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1499, '2026-07-09', 4740, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1500, '2026-07-10', 4840, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1501, '2026-07-13', 4846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1502, '2026-07-14', 4832, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1503, '2026-07-15', 4856, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1504, '2026-07-16', 4800, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1505, '2026-07-17', 4728, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1506, '2026-07-20', 4822, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1507, '2026-07-21', 4846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1508, '2026-07-22', 4830, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1509, '2026-07-23', 4854, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1510, '2026-07-24', 4804, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1511, '2026-07-27', 4794, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1512, '2026-07-28', 4762, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1513, '2026-07-29', 4790, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1514, '2026-07-30', 4740, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1515, '2026-07-31', 4672, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1516, '2026-08-03', 4654, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1517, '2026-08-04', 4664, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1518, '2026-08-05', 4678, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1519, '2026-08-06', 4674, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1520, '2026-08-07', 4656, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1521, '2026-08-10', 4628, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1522, '2026-08-11', 4558, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1523, '2026-08-12', 4638, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1524, '2026-08-13', 4690, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1525, '2026-08-14', 4680, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1526, '2026-08-17', 4724, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1527, '2026-08-18', 4730, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1528, '2026-08-19', 4718, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1529, '2026-08-20', 4800, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1530, '2026-08-21', 4892, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1531, '2026-08-24', 4866, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1532, '2026-08-25', 4848, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1533, '2026-08-26', 4786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1534, '2026-08-27', 4800, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1535, '2026-08-28', 4788, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1536, '2026-08-31', 4748, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1537, '2026-09-01', 4862, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1538, '2026-09-02', 4840, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1539, '2026-09-03', 4810, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1540, '2026-09-04', 4854, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1541, '2026-09-07', 4844, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1542, '2026-09-08', 4876, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1543, '2026-09-09', 4846, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1544, '2026-09-10', 4786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1545, '2026-09-11', 4786, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1546, '2026-09-14', 4764, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1547, '2026-09-15', 4768, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1548, '2026-09-16', 4822, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1549, '2026-09-17', 4740, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1550, '2026-09-18', 4836, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1551, '2026-09-21', 4978, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1552, '2026-09-22', 4972, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1553, '2026-09-23', 4896, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1554, '2026-09-24', 4874, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1555, '2026-09-28', 4828, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1556, '2026-09-29', 4814, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1557, '2026-09-30', 4770, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1558, '2026-10-08', 4724, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1559, '2026-10-09', 4724, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1560, '2026-10-12', 4654, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1561, '2026-10-13', 4660, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1562, '2026-10-14', 4730, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1563, '2026-10-15', 4742, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1564, '2026-10-16', 4756, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1565, '2026-10-19', 4728, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1566, '2026-10-20', 4692, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1567, '2026-10-21', 4668, '2026-10-22T09:00:00+08:00', 9, NULL, 925),
(1569, '2026-10-22', 4684, '2026-10-22T09:02:34.827+08:00', 10, 118, NULL),
(1816, '2026-10-22', 1.6414, '2026-10-22T19:05:16.126+08:00', 2, 120, NULL),
(1819, '2026-10-22', 4632, '2026-10-22T19:05:17.35+08:00', 10, 123, NULL),
(2579, '2025-12-22', 0.9043, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2580, '2026-05-19', 0.8695, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2581, '2026-03-20', 0.8808, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2582, '2026-03-30', 0.8818, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2583, '2026-01-12', 0.894, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2584, '2026-01-14', 0.8941, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2585, '2026-02-18', 0.8832, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2586, '2026-04-09', 0.8725, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2587, '2025-11-19', 0.9129, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2588, '2026-10-16', 0.8516, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2589, '2026-05-28', 0.8646, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2590, '2026-09-03', 0.8567, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2591, '2025-10-28', 0.9134, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2592, '2025-11-07', 0.9154, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2593, '2026-10-06', 0.8542, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2594, '2026-03-31', 0.879, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2595, '2026-05-29', 0.863, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2596, '2025-12-02', 0.9078, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2597, '2026-08-20', 0.857, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2598, '2026-05-11', 0.8676, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2599, '2025-11-04', 0.9167, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2600, '2026-02-09', 0.8853, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2601, '2025-12-18', 0.9046, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2602, '2026-04-01', 0.8764, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2603, '2025-10-21', 0.9161, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2604, '2026-07-16', 0.8637, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2605, '2026-07-24', 0.8632, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2606, '2026-01-02', 0.8963, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2607, '2026-07-07', 0.8661, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2608, '2026-07-22', 0.8635, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2609, '2026-07-14', 0.8635, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2610, '2026-04-23', 0.8717, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2611, '2026-10-15', 0.8523, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2612, '2025-12-10', 0.9077, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2613, '2026-02-02', 0.8887, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2614, '2025-12-15', 0.9052, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2615, '2026-02-19', 0.8832, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2616, '2026-06-23', 0.8656, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2617, '2026-05-07', 0.8681, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2618, '2026-03-02', 0.8819, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2619, '2026-04-15', 0.8702, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2620, '2026-02-03', 0.8877, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2621, '2026-08-03', 0.8612, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2622, '2025-10-20', 0.9163, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2623, '2026-07-20', 0.8629, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2624, '2026-06-24', 0.8685, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2625, '2026-09-18', 0.8536, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2626, '2026-01-26', 0.8915, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2627, '2026-01-28', 0.89, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2628, '2026-03-12', 0.8785, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2629, '2026-05-01', 0.8714, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2630, '2026-04-22', 0.8711, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2631, '2025-11-05', 0.9162, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2632, '2026-10-01', 0.8543, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2633, '2026-03-24', 0.8804, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2634, '2026-08-04', 0.86, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2635, '2026-08-13', 0.8589, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2636, '2026-10-05', 0.8542, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2637, '2026-09-02', 0.8565, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2638, '2026-01-07', 0.8974, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2639, '2026-09-10', 0.8556, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2640, '2026-05-05', 0.8713, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2641, '2026-03-04', 0.8822, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2642, '2026-05-21', 0.868, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2643, '2026-04-13', 0.8717, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2644, '2026-02-06', 0.8875, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2645, '2025-11-20', 0.9131, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2646, '2026-09-23', 0.8554, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2647, '2025-11-17', 0.9141, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2648, '2026-05-06', 0.8692, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2649, '2026-08-27', 0.8569, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2650, '2026-07-08', 0.8674, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2651, '2026-10-07', 0.8541, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2652, '2025-12-29', 0.9009, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2653, '2026-01-08', 0.8959, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2654, '2026-08-14', 0.8587, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2655, '2026-07-09', 0.8667, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2656, '2026-01-29', 0.8902, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2657, '2026-02-04', 0.8882, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2658, '2026-01-22', 0.8939, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2659, '2026-08-31', 0.8571, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2660, '2026-05-12', 0.8675, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2661, '2026-02-16', 0.8832, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2662, '2026-07-01', 0.8653, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2663, '2026-07-31', 0.8607, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2664, '2026-10-20', 0.8505, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2665, '2026-01-21', 0.8927, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2666, '2026-06-15', 0.8621, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2667, '2026-10-12', 0.8526, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2668, '2025-10-22', 0.9169, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2669, '2025-11-06', 0.9155, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2670, '2026-07-29', 0.8627, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2671, '2026-05-26', 0.8655, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2672, '2026-08-07', 0.8594, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2673, '2026-07-06', 0.8661, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2674, '2026-03-19', 0.8801, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2675, '2026-08-10', 0.8594, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2676, '2026-06-26', 0.8668, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2677, '2026-03-23', 0.8778, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2678, '2026-04-24', 0.8719, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2679, '2026-04-28', 0.8724, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2680, '2026-02-17', 0.8832, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2681, '2026-05-27', 0.865, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2682, '2026-07-17', 0.8641, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2683, '2025-12-17', 0.905, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2684, '2026-09-08', 0.8554, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2685, '2026-09-29', 0.8542, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2686, '2026-05-15', 0.8695, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2687, '2025-11-21', 0.9127, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2688, '2026-09-09', 0.8549, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2689, '2026-07-30', 0.8606, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2690, '2026-10-14', 0.8531, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2691, '2026-09-11', 0.8551, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2692, '2026-08-26', 0.8572, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2693, '2026-01-15', 0.8931, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2694, '2026-09-21', 0.853, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2695, '2026-04-14', 0.8697, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2696, '2026-06-16', 0.8623, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2697, '2026-10-13', 0.8524, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2698, '2026-01-20', 0.8924, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2699, '2026-06-10', 0.8643, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2700, '2026-04-08', 0.8716, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2701, '2026-04-10', 0.8715, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2702, '2026-02-11', 0.884, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2703, '2026-07-03', 0.8641, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2704, '2026-09-04', 0.8556, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2705, '2025-10-24', 0.9164, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2706, '2025-11-12', 0.915, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2707, '2026-03-16', 0.8792, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2708, '2025-11-27', 0.91, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2709, '2026-07-15', 0.8632, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2710, '2026-08-24', 0.8575, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2711, '2026-06-02', 0.8625, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2712, '2026-07-13', 0.8647, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2713, '2026-06-04', 0.8641, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2714, '2025-10-23', 0.9162, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2715, '2026-02-23', 0.8828, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2716, '2026-10-02', 0.8542, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2717, '2026-04-17', 0.8703, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2718, '2025-10-29', 0.9132, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2719, '2026-02-20', 0.8832, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2720, '2025-11-24', 0.9124, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2721, '2026-06-09', 0.8637, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2722, '2026-01-09', 0.8948, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2723, '2026-08-21', 0.8569, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2724, '2026-04-27', 0.8705, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2725, '2026-06-30', 0.865, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2726, '2026-10-19', 0.8509, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2727, '2026-09-16', 0.8547, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2728, '2026-08-19', 0.858, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2729, '2026-04-30', 0.8713, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2730, '2025-12-30', 0.8984, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2731, '2026-03-06', 0.8826, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2732, '2026-01-16', 0.8931, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2733, '2026-09-07', 0.8556, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2734, '2026-06-18', 0.8634, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2735, '2026-05-18', 0.8681, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2736, '2026-05-08', 0.8684, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2737, '2026-09-30', 0.8541, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2738, '2025-11-03', 0.9158, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2739, '2026-09-24', 0.8554, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2740, '2026-09-22', 0.8538, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2741, '2026-06-25', 0.8666, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2742, '2025-12-09', 0.9073, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2743, '2026-07-28', 0.8629, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2744, '2026-05-04', 0.8716, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2745, '2026-08-11', 0.8592, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2746, '2026-09-14', 0.8553, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2747, '2025-12-19', 0.9045, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2748, '2026-05-14', 0.8659, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2749, '2025-11-11', 0.9154, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2750, '2026-01-05', 0.8974, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2751, '2026-06-01', 0.8633, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2752, '2026-10-21', 0.8504, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2753, '2026-05-20', 0.868, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2754, '2026-06-22', 0.8639, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2755, '2026-08-12', 0.8588, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2756, '2026-03-25', 0.8825, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2757, '2025-11-13', 0.9129, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2758, '2025-10-30', 0.915, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2759, '2026-01-27', 0.8912, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2760, '2026-07-23', 0.8638, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2761, '2026-03-27', 0.882, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2762, '2026-05-13', 0.8668, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2763, '2026-08-28', 0.8573, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2764, '2025-12-11', 0.9065, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2765, '2026-03-13', 0.8804, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2766, '2026-03-09', 0.8842, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2767, '2025-12-31', 0.8974, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2768, '2026-03-17', 0.8778, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2769, '2025-12-16', 0.9048, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2770, '2025-12-23', 0.9032, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2771, '2026-06-08', 0.8653, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2772, '2026-04-21', 0.8706, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2773, '2025-12-04', 0.9081, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2774, '2026-06-11', 0.8643, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2775, '2026-02-12', 0.8825, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2776, '2025-12-03', 0.907, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2777, '2026-05-25', 0.8656, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2778, '2026-06-12', 0.8628, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2779, '2026-09-28', 0.8553, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2780, '2025-11-28', 0.9086, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2781, '2026-07-27', 0.8623, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2782, '2025-11-10', 0.9156, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2783, '2026-10-08', 0.8537, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2784, '2026-01-19', 0.8927, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2785, '2025-12-08', 0.9081, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2786, '2026-02-10', 0.8837, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2787, '2025-11-25', 0.9106, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2788, '2026-07-10', 0.8641, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2789, '2026-02-25', 0.8774, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2790, '2026-09-01', 0.8568, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2791, '2026-02-13', 0.883, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2792, '2026-06-05', 0.8654, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2793, '2026-03-05', 0.8825, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2794, '2026-03-10', 0.8772, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2795, '2026-01-13', 0.8936, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2796, '2025-10-27', 0.9152, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2797, '2026-03-18', 0.8786, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2798, '2025-12-25', 0.9007, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2799, '2026-06-03', 0.864, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2800, '2025-10-31', 0.9157, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2801, '2026-08-17', 0.8588, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2802, '2026-06-17', 0.8622, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2803, '2026-05-22', 0.8669, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2804, '2026-07-21', 0.8627, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2805, '2026-03-26', 0.8828, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2806, '2026-09-15', 0.8553, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2807, '2026-04-02', 0.8787, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2808, '2026-02-05', 0.8878, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2809, '2026-06-29', 0.8664, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2810, '2026-06-19', 0.8637, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2811, '2025-11-26', 0.9096, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2812, '2026-02-24', 0.8798, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2813, '2025-12-26', 0.9012, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2814, '2026-02-27', 0.8769, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2815, '2026-01-06', 0.8962, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2816, '2026-08-25', 0.857, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2817, '2026-09-17', 0.8545, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2818, '2026-10-09', 0.8524, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2819, '2025-12-01', 0.9075, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2820, '2026-04-06', 0.8782, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2821, '2025-11-18', 0.9129, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2822, '2025-12-12', 0.9058, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2823, '2026-08-18', 0.8593, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2824, '2026-03-03', 0.8865, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2825, '2026-03-11', 0.8772, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2826, '2026-04-29', 0.8722, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2827, '2026-10-22', 0.8507, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2828, '2026-04-20', 0.8703, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2829, '2026-08-06', 0.8599, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2830, '2026-09-25', 0.8555, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2831, '2026-02-26', 0.8741, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2832, '2026-04-07', 0.8754, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2833, '2026-07-02', 0.8646, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2834, '2026-04-16', 0.8716, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2835, '2026-01-30', 0.8901, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2836, '2025-12-24', 0.9017, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2837, '2026-08-05', 0.8601, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2838, '2026-01-23', 0.8927, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2839, '2025-12-05', 0.9079, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2840, '2026-04-03', 0.8779, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2841, '2025-11-14', 0.9129, '2026-10-22T20:00:00+08:00', 29, NULL, 926),
(2843, '2026-10-22', 0.851, '2026-10-22T20:16:56.96+08:00', 29, 132, NULL),
(3092, '2026-10-22', 4630, '2026-10-23T02:40:21.872+08:00', 10, 137, NULL),
(3093, '2026-10-23', 0.8513, '2026-10-23T02:40:22.22+08:00', 29, 140, NULL),
(3098, '2026-10-23', 4630, '2026-10-23T12:40:39.515+08:00', 10, 146, NULL),
(3101, '2026-10-23', 0.8507, '2026-10-23T12:40:39.86+08:00', 29, 149, NULL);

COMMIT;

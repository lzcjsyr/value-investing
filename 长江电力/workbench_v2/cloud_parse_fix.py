from cloud import *
def main():
 cli('+table-get','--table-id',state['tables'][R])
 formulas(R,{
 '响应去转义':'SUBSTITUTE([原始响应],CHAR(92),"")',
 '国债数据行':'IFERROR(REGEXEXTRACT([响应去转义],"中债国债收益率曲线</td>(.*?)</tr>").FIRST(),"")',
 '三峡数据对象':'IFERROR(REGEXEXTRACT([响应去转义],"([{][^{}]*60106980[^{}]*[}])").FIRST(),"")',
 '日期V2':'IFERROR(SWITCH([指标代码],"TENCENT-600900",[观测日期],"CHINABOND-CGB10Y",REGEXEXTRACT([响应去转义],"<th>([0-9-]+)").FIRST(),"CJH-SX-LEVEL",TEXT(DATE(1970,1,1)+VALUE(REGEXEXTRACT([三峡数据对象],CHAR(34)&"tm"&CHAR(34)&":([0-9]+)").FIRST())/86400000+8/24,"YYYY-MM-DD"),""),"")',
 '数值V2':'IFERROR(SWITCH([指标代码],"TENCENT-600900",[数值候选],"CHINABOND-CGB10Y",VALUE(REGEXEXTRACTALL(REGEXREPLACE([国债数据行],"<!--.*?-->",""),"<td[^>]*>([0-9.]+)</td>").LISTCOMBINE().NTH(7)),"CJH-SX-LEVEL",VALUE(REGEXEXTRACT([三峡数据对象],CHAR(34)&"z"&CHAR(34)&":"&CHAR(34)&"([0-9.]+)").FIRST()),""),"")',
 '校验V2':'IFERROR(IF(AND(REGEXMATCH([日期V2],"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"),DAYS([采集时间],TODATE([日期V2]))>=0,DAYS([采集时间],TODATE([日期V2]))<=7,NOT(ISBLANK([数值V2])),SWITCH([指标代码],"TENCENT-600900",AND(SPLIT([原始响应],"~").NTH(3)="600900",VALUE([数值V2])>0,VALUE([数值V2])<1000),"CHINABOND-CGB10Y",AND(VALUE([数值V2])>=0,VALUE([数值V2])<20,CONTAINTEXT([响应去转义],"10<!-- 年 -->年")),"CJH-SX-LEVEL",AND(VALUE([数值V2])>100,VALUE([数值V2])<200),FALSE())),1,0),0)',
 '观察键V2':'[指标代码]&"|"&[日期V2]&"|"&[数值V2]',
 })
 h='V2_11市场观察'
 fs=cli('+field-list','--table-id',state['tables'][h])['fields']
 if not any(x['name']=='云端数值原文' for x in fs):cli('+field-create','--table-id',state['tables'][h],'--json',json.dumps(t('云端数值原文'),ensure_ascii=False))
 formulas(h,{'统一数值':'IF(ISBLANK([数值]),IFERROR(VALUE([云端数值原文]),""),[数值])','质量有效':'IFERROR(IF(AND(NOT(ISBLANK([统一数值])),VALUE([统一数值])>=0),1,0),0)'})
if __name__=='__main__':main()

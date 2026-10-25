from cloud import *
def lit(s):return json.dumps(s,ensure_ascii=False)
def rx(field,pattern):return f'REGEXEXTRACT([{field}],{lit(pattern)}).FIRST()'
def main():
 cli('+table-list');cli('+table-get','--table-id',state['tables'][R])
 definitions={
  '国债行':f'IFERROR({rx("原始响应",r"中债国债收益率曲线</td>([\s\S]*?)</tr>")},"")',
  '水库对象':f'IFERROR({rx("原始响应",r"(\{[^{{}}]*\"stcd\":\"60106980\"[^{{}}]*\})")},"")',
  '日期候选':f'IFERROR(SWITCH([指标代码],"TENCENT-600900",LEFT(SPLIT([原始响应],"~").NTH(31),8),"CHINABOND-CGB10Y",{rx("原始响应",r"<th>([0-9]{4}-[0-9]{2}-[0-9]{2})\(%\)</th>")},"CJH-SX-LEVEL",TEXT(DATE(1970,1,1)+VALUE({rx("水库对象",r"\"tm\":([0-9]+)")})/86400000+8/24,"YYYY-MM-DD"),""),"")',
  '观测日期':'IF([指标代码]="TENCENT-600900",LEFT([日期候选],4)&"-"&MID([日期候选],5,2)&"-"&RIGHT([日期候选],2),[日期候选])',
  '数值候选':f'IFERROR(SWITCH([指标代码],"TENCENT-600900",VALUE(SPLIT([原始响应],"~").NTH(4)),"CHINABOND-CGB10Y",VALUE(REGEXEXTRACTALL(REGEXREPLACE([国债行],"<!--[\\s\\S]*?-->",""),"<td[^>]*>([0-9.]+)</td>").LISTCOMBINE().NTH(7)),"CJH-SX-LEVEL",VALUE({rx("水库对象",r"\"z\":\"([0-9.]+)\"")}),""),"")',
  '采集时间文本':'TEXT([采集时间],"YYYY-MM-DD hh:mm:ss")',
  '日期有效':'IFERROR(IF(AND(REGEXMATCH([观测日期],"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"),DAYS([采集时间],TODATE([观测日期]))>=0,DAYS([采集时间],TODATE([观测日期]))<=7),1,0),0)',
  '校验通过':'IFERROR(IF(AND([日期有效]=1,ISNUMBER([数值候选]),SWITCH([指标代码],"TENCENT-600900",AND(SPLIT([原始响应],"~").NTH(3)="600900",[数值候选]>0,[数值候选]<1000),"CHINABOND-CGB10Y",AND([数值候选]>=0,[数值候选]<20,CONTAINTEXT([原始响应],"10<!-- 年 -->年")),"CJH-SX-LEVEL",AND([数值候选]>100,[数值候选]<200),FALSE())),1,0),0)',
  '观察键':'[指标代码]&"|"&[观测日期]&"|"&[数值候选]',
 }
 formulas(R,definitions)
 print('Parser fields created')
if __name__=='__main__':main()

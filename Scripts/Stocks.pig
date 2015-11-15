/************************************************************************
	Stock analysis tasks with Hive
	
	pig /media/sf_Data/Hadoop/Scripts/tmp.pig >/media/sf_Data/Hadoop/Scripts/pig.log 2>&1 &
	pig -x tez /media/sf_Data/Hadoop/Scripts/tmp.pig >/media/sf_Data/Hadoop/Scripts/pig.log 2>&1 &
	hadoop fs -du -h /user/root/data/input
	get the HDFS files generated by PIG to local files system (includes dir and files)
	hadoop fs -get /user/root/data/input /media/sf_Data/input
*************************************************************************/
A = LOAD '/user/root/data/stocks/stocks.csv' using PigStorage(',')
  	AS (exchange1:chararray, symbol:chararray,
            date:chararray, open:float, high:float, low:float, close:float,
            volume:int, adj_close:float);
B = ORDER A BY exchange1,symbol;
C1 = FILTER B BY exchange1 == 'NASDAQ' and symbol == 'AAPL';
C2 = FILTER B BY exchange1 == 'NASDAQ' and symbol == 'INTC';
C3 = FILTER B BY exchange1 == 'NYSE' and symbol == 'GE';
C4 = FILTER B BY exchange1 == 'NYSE' and symbol == 'IBM';
STORE C1 into '/user/root/data/input/AAPL' using PigStorage(',');
STORE C2 into '/user/root/data/input/INTC' using PigStorage(',');
STORE C3 into '/user/root/data/input/GE' using PigStorage(',');
STORE C4 into '/user/root/data/input/IBM' using PigStorage(',');


SET default_parallel 10;
SET exectype tez;
SET verbose false;
SET brief false;
SET DEBUG ERROR;
SET pig.logfile /media/sf_Data/Hadoop/Scripts/pig1.log;

dividends = load '/user/root/data/dividends/dividends.csv'  using PigStorage(',')
		as (exchange1:chararray, symbol:chararray,
            date:chararray, dividend:float);
grouped   = group dividends by symbol;
describe grouped;
avgdiv  = foreach grouped generate group, AVG(dividends.dividend);
avgdiv10 = LIMIT avgdiv 10;
dump avgdiv10;
cntd   = foreach grouped generate group, COUNT(dividends);
describe cntd;
cntd10 = LIMIT cntd 10;
dump cntd10;
cntdf   = FILTER cntd by $0 == 'IBM';
cntdf10 = LIMIT cntdf 10;
dump cntdf;


daily = LOAD '/user/root/data/stocks/stocks.csv' using PigStorage(',')
  	AS (exchange1:chararray, symbol:chararray,
            date:chararray, open:float, high:float, low:float, close:float,
            volume:int, adj_close:float);
groupeddaily   = group daily by symbol;        
rough = foreach daily generate volume * close;
rough10 = LIMIT rough 10;
dump rough10;
cntdaily   = foreach groupeddaily generate group, COUNT(daily);
cntdaily10 = LIMIT cntdaily 10;
dump cntdaily10;

jnd   = join dividends by symbol, daily by symbol;
describe jnd;
jnd10 = LIMIT jnd 10;
dump jnd10;

jnd2cols   = join daily by (symbol, date), dividends by (symbol, date);
describe jnd2cols;
jnd2cols10 = LIMIT jnd2cols 10;
dump jnd2cols10;

jndlo   = join daily by (symbol, date) left outer, dividends by (symbol, date);
describe jndlo;
jndlo10 = LIMIT jndlo 10;
dump jndlo10;

grpdexg = DISTINCT (FOREACH daily GENERATE exchange1);
grpsym =  DISTINCT (FOREACH daily GENERATE symbol);
dump grpdexg;
dump grpsym;

describe groupeddaily;
stockmaxmin = FOREACH groupeddaily GENERATE FLATTEN(daily.(symbol)), MAX(daily.high), MIN(daily.low);
describe stockmaxmin;
stockmaxmin10 = LIMIT stockmaxmin 10;
dump stockmaxmin10;
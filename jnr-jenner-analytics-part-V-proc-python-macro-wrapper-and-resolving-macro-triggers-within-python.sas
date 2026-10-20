/*---
c:/utl/jnr-jenner-analytics-part-V-proc-python-macro-wrapper-and-resolving-macro-triggers-within-python.sas
---*/

Jenner Analytics part V proc python macro wrapper and resolving macro triggers within python

Too long to post see
https://github.com/rogerjdeangelis/nr-jenner-analytics-part-V-proc-python-macro-wrapper-and-resolving-macro-triggers-within-python

SOAPBOX ON
SAS and the SLC do not resolve macro triggers in R and Python code; Jenner does.
This is a big deal, especially using Jenner macros to generate python and R code.
Jenner allows calling python within a Jenner dtastep.
SOAPBOX OFF

CONTENTS

  1 Proc python vanilla interface
  2 Proc python resolving macro variable in the python script
  3 Proc python macro wrapper
  4 Calling python within a Jenner datastep

STATUS
https://github.com/rogerjdeangelis/jnr-jenner-analytics-part-I-inline-drop-down-to-duckdb-sql
https://github.com/rogerjdeangelis/jnr-jenner-analytics-part-II-drop-down-to-open-source-spss-run-regression
https://github.com/rogerjdeangelis/jnr-jenner-analytics-part-III-inline-drop-down-to-open-source-matlab-summarize-data
https://github.com/rogerjdeangelis/jnr-jenner-analytics-part-IV-inline-drop-down-to-poweshell-add-column-to-excell-sheet
https://github.com/rogerjdeangelis/nr-jenner-analytics-part-V-proc-python-macro-wrapper-and-resolving-macro-triggers-within-python

/******************************************************************************************************************/
/* 1  create input parquet file                                                                                   */
/******************************************************************************************************************/

%utlfkil(d:/parquet/class.parquet);

libname prq parquet "d:/parquet";

options validvarname=v7;

data prq.class;
  informat
     name $8.
     sex $1.
     age 8.
     height 8.
     weight 8.
;
input name sex age height weight;
cards4;
Alfred M 14 69 112.5
Alice F 13 56.5 84
Barbara F 13 65.3 98
Carol F 14 62.8 102.5
Henry M 14 63.5 102.5
;;;;
run;

/******************************************************************************************************************/
/* 2  proc python vanilla interface                                                                               */
/*    code also outputs a dill pickel on the pthon workspace dill.dump_module("d:/pkl/workspace.pkl")             */
/*                                                                                                                */
/*  Why use your own installed python                                                                             */
/*    1 you can add packages beyond the default collection of packages                                            */
/*    2 run other versions of python minconda, anacondat, and wsl ubuntu python                                   */
/******************************************************************************************************************/

/*--- YOU NEED THIS TO USE YOUR OWN PYTHON ----*/
options set=PROC_PYPATH "D:\py314\python.exe";
proc python;
submit;
from pandasql import sqldf
import pandas as pd
import dill;
have = pd.read_parquet(
  "d:/parquet/class.parquet"
   ,engine="pyarrow"
)
want = sqldf("""
  select
       sex
      ,avg(age)    as avgAge
      ,avg(height) as avgHgt
      ,avg(weight) as avgWgt
  from
      have
  group
      by sex
  order
      by sex;
  """);

print(want)

want.to_parquet(
  "d:/parquet/want.parquet"
  ,engine="pyarrow"
  ,compression="snappy"
  ,index=False
)
dill.dump_module("d:/pkl/workspace.pkl")
endsubmit;
run;

libname prq parquet "d:/parquet";

options nocenter;
proc print data=prq.want;
format _numeric_ 6.2;
title "Back to jenner";
run;


LIST: 14:04:16
==============
PYTHON
  sex     avgAge     avgHgt      avgWgt
0   F  13.333333  61.533333   94.833333
1   M  14.000000  66.250000  107.500000

Back to jenner

Obs  sex  avgAge  avgHgt  avgWgt

  1  F     13.33   61.53   94.83
  2  M     14.00   66.25  107.50


LOG:  14:04:16
==============

NOTE: Copyright (c) 2026 Jenner Analytics Ltd., London, England.
NOTE: Jenner v1.5.102 (build v1.5.102+67ce60c837.20261020T035203Z)
      Licensed to Roger DeAngelis, Serial 3BF7B3E6.
NOTE: DATA _null_

autexec started.

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: Library WORKX assigned path=d:\wpswrkx.
NOTE: DATA workx.class

NOTE: Processing inline DATALINES (19 lines)

NOTE: Read 19 rows from DATALINES.
NOTE: The data set WORKX.CLASS has 19 observations and 5 variables.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

LOG:  14:04:16
NOTE: DATA _null_ completed. Output written to FILE PRINT
NOTE: Option SASAUTOS changed to c:/otojnr.
NOTE: DATA _null_

NOTE: Reading from fileref c:/jnr/runsas_selection.sas (c:/jnr/runsas_selection.sas)
    1 options set=PROC_PYPATH "D:\py314\python.exe";
    2 proc python;
    3 submit;
    4 from pandasql import sqldf
    5 import pandas as pd
    6 import dill;
    7 have = pd.read_parquet(
    8   "d:/parquet/class.parquet"
    9    ,engine="pyarrow"
   10 )
   11 want = sqldf("""
   12   select
   13        sex
   14       ,avg(age)    as avgAge
   15       ,avg(height) as avgHgt
   16       ,avg(weight) as avgWgt
   17   from
   18       have
   19   group
   20       by sex
   21   order
   22       by sex;
   23   """);
   24
   25 print(want)
   26
   27 want.to_parquet(
   28   "d:/parquet/want.parquet"
   29   ,engine="pyarrow"
   30   ,compression="snappy"
   31   ,index=False
   32 )
   33 dill.dump_module("d:/pkl/workspace.pkl")
   34 endsubmit;
   35 run;
   36
   37 libname prq parquet "d:/parquet";
   38
   39 options nocenter;
   40 proc print data=prq.want;
   41 format _numeric_ 6.2;
   42 title "Back to jenner";
   43 run;

NOTE: Read 43 rows from c:/jnr/runsas_selection.sas.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

autoexec completed  14:04:16

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
NOTE: PROC PYTHON step completed.
NOTE: Library PRQ assigned path=d:/parquet.
NOTE: PROC PRINT data=prq.want

NOTE: PROC PRINT completed: 2 observations printed, 4 variables


/******************************************************************************************************************/
/* 3  resolve macro triggers in your python code. Big deal to create addition python code?                        */
/******************************************************************************************************************/

%let inp=d:/parquet/class.parquet;
%let out=d:/parquet/want.parquet;

/*--- PYTHON EXECUTES THE SAME EXACT CODE THAT PROC SQL WOULD EXECUTE ---*/
%macro procsql;
      select
       sex
      ,avg(age)    as avgAge
      ,avg(height) as avgHgt
      ,avg(weight) as avgWgt
  from
      have
  group
      by sex
  order
      by sex;
%mend procsql;

/*--- you need to set this path if you want to:
    1. use packages not available with builtin collection of packages
    2. for miniconda, anaconda or wsl ubuntu python ---*/

options set=PROC_PYPATH "D:\py314\python.exe";
proc python;
submit;
from pandasql import sqldf
import pandas as pd
import dill;

have = pd.read_parquet(
  "&inp"
   ,engine="pyarrow"
)

want = sqldf(""" %procsql """);

want.to_parquet(
  "d:/parquet/want.parquet"
  ,engine="pyarrow"
  ,compression="snappy"
  ,index=False
)

print(want)
dill.dump_module("d:/pkl/workspace.pkl")
endsubmit;
run;

options nocenter;
proc print data="&out";
format _numeric_ 6.2;
title "Back to jenner";
run;

LIST: 14:14:51
==============
PYTHON
  sex     avgAge     avgHgt      avgWgt
0   F  13.333333  61.533333   94.833333
1   M  14.000000  66.250000  107.500000

Back to jenner

Obs  sex  avgAge  avgHgt  avgWgt

  1  F     13.33   61.53   94.83
  2  M     14.00   66.25  107.50

LOG:  14:14:51
==============

NOTE: Copyright (c) 2026 Jenner Analytics Ltd., London, England.
NOTE: Jenner v1.5.102 (build v1.5.102+67ce60c837.20261020T035203Z)
      Licensed to Roger DeAngelis, Serial 3BF7B3E6.
NOTE: DATA _null_

autexec started.

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: Library WORKX assigned path=d:\wpswrkx.
NOTE: DATA workx.class

NOTE: Processing inline DATALINES (19 lines)

NOTE: Read 19 rows from DATALINES.
NOTE: The data set WORKX.CLASS has 19 observations and 5 variables.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

LOG:  14:14:51
NOTE: DATA _null_ completed. Output written to FILE PRINT
NOTE: Option SASAUTOS changed to c:/otojnr.
NOTE: DATA _null_

NOTE: Reading from fileref c:/jnr/runsas_selection.sas (c:/jnr/runsas_selection.sas)
    1 %let inp=d:/parquet/class.parquet;
    2 %let out=d:/parquet/want.parquet;
    3
    4 /*--- PYTHON EXECUTES THE SAME EXACT CODE THAT PROC SQL WOULD EXECUTE ---*/
    5 %macro procsql;
    6       select
    7        sex
    8       ,avg(age)    as avgAge
    9       ,avg(height) as avgHgt
   10       ,avg(weight) as avgWgt
   11   from
   12       have
   13   group
   14       by sex
   15   order
   16       by sex;
   17 %mend procsql;
   18
   19 /*--- you need to set this path if you want to:
   20     1. use packages not available with builtin collection of packages
   21     2. for miniconda, anaconda or wsl ubuntu python ---*/
   22
   23 options set=PROC_PYPATH "D:\py314\python.exe";
   24 proc python;
   25 submit;
   26 from pandasql import sqldf
   27 import pandas as pd
   28 import dill;
   29
   30 have = pd.read_parquet(
   31   "&inp"
   32    ,engine="pyarrow"
   33 )
   34
   35 want = sqldf(""" %procsql """);
   36
   37 print(want)
   38 dill.dump_module("d:/pkl/workspace.pkl")
   39 endsubmit;
   40 run;
   41
   42 options nocenter;
   43 proc print data="&out";
   44 format _numeric_ 6.2;
   45 title "Back to jenner";
   46 run;

NOTE: Read 46 rows from c:/jnr/runsas_selection.sas.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

autoexec completed  14:14:51

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
NOTE: PROC PYTHON step completed.
NOTE: PROC PRINT data=d:/parquet/want.parquet

NOTE: PROC PRINT completed: 2 observations printed, 4 variables

/******************************************************************************************************************/
/* 3  macro wrapper for python code                                                                               */
/******************************************************************************************************************/

/*--- EXAMPLE AVERAGES FOR FEMALES ONLY ---*/

%utlfkil(d:/parquet/want.parquet);

%macro runPy(
  gender=F
  ,inp=d:/parquet/class.parquet
  ,out=d:/parquet/want.parquet
  )/des="Example of wrapping python is a Kenner macro";
options set=PROC_PYPATH "D:\py314\python.exe";
proc python;
submit;
from pandasql import sqldf
import pandas as pd
import dill;
have = pd.read_parquet(
  "&inp"
   ,engine="pyarrow"
)
want = sqldf("""
  select
       sex
      ,avg(age)    as avgAge
      ,avg(height) as avgHgt
      ,avg(weight) as avgWgt
  from
      have
  where
      sex ='&gender'
  """);

print(want)

want.to_parquet(
  "&out"
  ,engine="pyarrow"
  ,compression="snappy"
  ,index=False
)
dill.dump_module("d:/pkl/workspace.pkl")
endsubmit;
run;

options nocenter;
proc print data="&out";
format _numeric_ 6.2;
title "Back to jenner";

run;

%mend runPy;

%runpy;

LIST: 14:43:47
==============

  sex     avgAge     avgHgt     avgWgt
0   F  13.333333  61.533333  94.833333

Back to jenner

  Obs  sex  avgAge  avgHgt  avgWgt

    1  F     13.33   61.53   94.83

LOG:  14:43:47
==============

NOTE: Copyright (c) 2026 Jenner Analytics Ltd., London, England.
NOTE: Jenner v1.5.102 (build v1.5.102+67ce60c837.20261020T035203Z)
      Licensed to Roger DeAngelis, Serial 3BF7B3E6.
NOTE: DATA _null_

autexec started.

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: Library WORKX assigned path=d:\wpswrkx.
NOTE: DATA workx.class

NOTE: Processing inline DATALINES (19 lines)

NOTE: Read 19 rows from DATALINES.
NOTE: The data set WORKX.CLASS has 19 observations and 5 variables.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

LOG:  14:43:47
NOTE: DATA _null_ completed. Output written to FILE PRINT
NOTE: Option SASAUTOS changed to c:/otojnr.
NOTE: DATA _null_

NOTE: Reading from fileref c:/jnr/runsas_selection.sas (c:/jnr/runsas_selection.sas)
    1 %macro runPy(
    2   gender=F
    3   ,inp=d:/parquet/class.parquet
    4   ,out=d:/parquet/want.parquet
    5   )/des="Example of wrapping python is a Kenner macro";
    6 options set=PROC_PYPATH "D:\py314\python.exe";
    7 proc python;
    8 submit;
    9 from pandasql import sqldf
   10 import pandas as pd
   11 import dill;
   12 have = pd.read_parquet(
   13   "&inp"
   14    ,engine="pyarrow"
   15 )
   16 want = sqldf("""
   17   select
   18        sex
   19       ,avg(age)    as avgAge
   20       ,avg(height) as avgHgt
   21       ,avg(weight) as avgWgt
   22   from
   23       have
   24   where
   25       sex ='&gender'
   26   """);
   27
   28 print(want)
   29
   30 want.to_parquet(
   31   "&out"
   32   ,engine="pyarrow"
   33   ,compression="snappy"
   34   ,index=False
   35 )
   36 dill.dump_module("d:/pkl/workspace.pkl")
   37 endsubmit;
   38 run;
   39
   40 options nocenter;
   41 proc print data="&out";
   42 format _numeric_ 6.2;
   43 title "Back to jenner";
   44
   45 run;
   46
   47 %mend runPy;
   48
   49 %runpy;

NOTE: Read 49 rows from c:/jnr/runsas_selection.sas.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

autoexec completed  14:43:47

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
NOTE: PROC PYTHON step completed.
NOTE: PROC PRINT data=d:/parquet/want.parquet

NOTE: PROC PRINT completed: 1 observations printed, 4 variables

/******************************************************************************************************************/
/* 4  calling python within a Jenner datastep                                                                     */
/******************************************************************************************************************/

%macro runpy2(arg);
options set=PROC_PYPATH "D:\py314\python.exe";
proc python;
submit;
import math;
import pandas as pd
area = math.pi * &arg * &arg;
print("radius =", &arg, "area =", area)
endsubmit;
run;
%mend runpy2;

%symdel radii / nowarn;

data _null_;
  do radii=1 to 4;
    call symputx('radii',radii,'G');
    rc=dosubl('%runpy2(&radii)');
  end;
run;


LIST: 15:23:11

radius = 1 area = 3.141
radius = 2 area = 12.57
radius = 3 area = 28.27
radius = 4 area = 50.27


LOG:  15:23:11
==============

NOTE: Copyright (c) 2026 Jenner Analytics Ltd., London, England.
NOTE: Jenner v1.5.102 (build v1.5.102+67ce60c837.20261020T035203Z)
      Licensed to Roger DeAngelis, Serial 3BF7B3E6.
NOTE: DATA _null_

autexec started.

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.02 seconds
NOTE: Library WORKX assigned path=d:\wpswrkx.
NOTE: DATA workx.class

NOTE: Processing inline DATALINES (19 lines)

NOTE: Read 19 rows from DATALINES.
NOTE: The data set WORKX.CLASS has 19 observations and 5 variables.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

LOG:  15:23:11
NOTE: DATA _null_ completed. Output written to FILE PRINT
NOTE: Option SASAUTOS changed to c:/otojnr.
NOTE: DATA _null_

NOTE: Reading from fileref c:/jnr/runsas_selection.sas (c:/jnr/runsas_selection.sas)
    1 %macro runpy2(arg);
    2 options set=PROC_PYPATH "D:\py314\python.exe";
    3 proc python;
    4 submit;
    5 import math;
    6 import pandas as pd
    7 area = math.pi * &arg * &arg;
    8 print("radius =", &arg, "area =", area)
    9 endsubmit;
   10 run;
   11 %mend runpy2;
   12
   13 %symdel radii / nowarn;
   14
   15 %put xxxx &radii xxxx;
   16
   17 data _null_;
   18   do radii=1 to 4;
   19     call symputx('radii',radii,'G');
   20     rc=dosubl('%runpy2(&radii)');
   21   end;
   22 run;

NOTE: Read 22 rows from c:/jnr/runsas_selection.sas.
NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
NOTE: DATA _null_

autoexec completed  15:23:11

NOTE: DATA elapsed:
  wall  0.00 seconds
  cpu   0.00 seconds
WARNING: Apparent symbolic reference RADII not resolved.
xxxx &radii xxxx
NOTE: DATA _null_

NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
radius = 1 area = 3.141592653589793

NOTE: PROC PYTHON step completed.
NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
radius = 2 area = 12.566370614359172

NOTE: PROC PYTHON step completed.
NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
radius = 3 area = 28.274333882308138

NOTE: PROC PYTHON step completed.
NOTE: Option SET changed to PROC_PYPATH D:\py314\python.exe.
NOTE: PROC PYTHON step executing.
radius = 4 area = 50.26548245743669

NOTE: PROC PYTHON step completed.

NOTE: DATA elapsed:
  wall  9.24 seconds
  cpu   4.75 seconds

  options set=PROC_PYPATH "D:\py314\python.exe";
  proc python;
   submit;
   input math;
   import pandas as pd
   area = math.pi * &radii * &radii;

/*--- END ---*/

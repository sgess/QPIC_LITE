function run_dir = WRITE_CMD(cmd_dir, name,memory,tasks,run_time)

%Command file
myfileout = [cmd_dir 'qpic.e.cmd_' name];
fidout = fopen(myfileout, 'w');

%Date string
dt = datestr(now, 'mmm dd HH:MM:SS');
[~, S] = weekday(dt);
year = datestr(now, 'yyyy');

%User and run directory
user = getenv('USER');
run_dir = ['/u/scratch/' user(1) '/' user '/' name];

%Job options
nt  = num2str(tasks);
mem = num2str(memory);
rt  = [num2str(run_time) ':00:00'];

%Write qpic.e.cmd
fprintf(fidout,...
    ['#!/bin/csh -f\n'...
    '#  qpic.e.cmd\n'...
    '#\n'...
    '#  UGE job for qpic.e built ' S ' ' dt ' PDT ' year '\n'...
    '#\n'...
    '#  The following items pertain to this script\n'...
    '#  Use current working directory\n'...
    '#$ -cwd\n'...
    '#  input           = /dev/null\n'...
    '#  output          = ' run_dir '/qpic.e.joblog\n'...
    '#$ -o ' run_dir '/qpic.e.joblog.$JOB_ID\n'...
    '#  error           = Merged with joblog\n'...
    '#$ -j y\n'...
    '#  The following items pertain to the user program\n'...
    '#  user program    = ' run_dir '/qpic.e\n'...
    '#  arguments       = \n'...
    '#  program input   = Specified by user program\n'...
    '#  program output  = Specified by user program\n'...
    '#  Parallelism:  ' nt '-way parallel\n'...
    '#  Resources requested\n'...
    '#$ -pe dc* ' nt '\n'...
    '#$ -l h_data=' mem 'M,h_rt=' rt '\n'...
    '# # #\n'...
    '#\n'...
    '#  Name of application for log\n'...
    '#$ -v QQAPP=openmpi\n'...
    '#  Email address to notify\n'...
    '#$ -M ' user '@mail\n'...
    '#  Notify at beginning and end of job\n'...
    '#$ -m bea\n'...
    '#  Job is not rerunable\n'...
    '#$ -r n\n'...
    '#  Uncomment the next line to have your environment variables used by SGE\n'...
    '#$ -V\n'...
    '#\n'...
    '# Initialization for mpi parallel execution\n'...
    '#\n'...
    '  unalias *\n'...
    '  set qqversion = \n'...
    '  set qqapp     = "openmpi parallel"\n'...
    '  set qqptasks  = ' nt '\n'...
    '  set qqidir    = ' run_dir '\n'...
    '  set qqjob     = qpic.e\n'...
    '  set qqodir    = ' run_dir '\n'...
    '  cd     ' run_dir '\n'...
    '  source /u/local/bin/qq.sge/qr.runtime\n'...
    '  if ($status != 0) exit (1)\n'...
    '#\n'...
    '  echo "UGE job for qpic.e built ' S ' ' dt ' PDT ' year '"\n'...
    '  echo ""\n'...
    '  echo "  qpic.e directory:"\n'...
    '  echo "    "' run_dir '\n'...
    '  echo "  Submitted to UGE:"\n'...
    '  echo "    "$qqsubmit\n'...
    '  echo "  ''scratch'' directory (on each node):"\n'...
    '  echo "    $qqscratch"\n'...
    '  echo "  qpic.e ' nt '-way parallel job configuration:"\n'...
    '  echo "    $qqconfig" | tr "\\\\" "\\n"\n'...
    '#\n'...
    '  echo ""\n'...
    '  echo "qpic.e started on:   "` hostname -s `\n'...
    '  echo "qpic.e started at:   "` date `\n'...
    '  echo ""\n'...
    '#\n'...
    '# Run the user program\n'...
    '#\n'...
    '\n'...
    '  source /u/local/Modules/default/init/modules.csh\n'...
    '  module load intel/11.1\n'...
    '  module load openmpi/1.4\n'...
    '\n'...
    '  echo qpic.e -nt ' nt ' "" \\>\\& qpic.e.output.$JOB_ID\n'...
    '  echo ""\n'...
    '\n'...
    '  setenv PATH /u/local/bin:$PATH\n'...
    '\n'...
    '  time mpiexec -n ' nt ' -machinefile $QQ_NODEFILE  \\\n'...
    '         ' run_dir '/qpic.e  >& ' run_dir '/qpic.e.output.$JOB_ID \n'...
    '\n'...
    '  echo ""\n'...
    '  echo "qpic.e finished at:  "` date `\n'...
    '\n'...
    '#\n'...
    '# Cleanup after mpi parallel execution\n'...
    '#\n'...
    '  source /u/local/bin/qq.sge/qr.runtime\n'...
    '#\n'...
    '  echo "-------- ' run_dir '/qpic.e.joblog.$JOB_ID --------" >> /u/local/apps/queue.logs/openmpi.log.parallel\n'...
    ' if (`wc -l ' run_dir '/qpic.e.joblog.$JOB_ID  | awk ''{print $1}''` >= 1000) then\n'...
    '        head -50 ' run_dir '/qpic.e.joblog.$JOB_ID >> /u/local/apps/queue.logs/openmpi.log.parallel\n'...
    '        echo " "  >> /u/local/apps/queue.logs/openmpi.log.parallel\n'...
    '        tail -10 ' run_dir '/qpic.e.joblog.$JOB_ID >> /u/local/apps/queue.logs/openmpi.log.parallel\n'...
    '  else\n'...
    '        cat ' run_dir '/qpic.e.joblog.$JOB_ID >> /u/local/apps/queue.logs/openmpi.log.parallel\n'...
    '  endif\n'...
    '#  cat            ' run_dir '/qpic.e.joblog.$JOB_ID           >> /u/local/apps/queue.logs/openmpi.log.parallel\n'...
    '  exit (0)\n']);
    
fclose(fidout);
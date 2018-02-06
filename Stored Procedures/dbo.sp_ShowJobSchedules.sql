SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[sp_ShowJobSchedules]
as
---------------------------------------------------------------------------------------------------
-- Date Created: September 21, 2006
-- Author:       William McEvoy
--               
-- Description:  This procedure produces a report that details the schedule information for all
--               scheduled jobs on the server.
--               
---------------------------------------------------------------------------------------------------
set nocount on

select 'Server'       = left(@@ServerName,20),
       'JobName'      = left(S.name,50),
	   'StepName'	  = CONVERT(NVARCHAR(2),S2.step_id) +'. '+ LEFT(S2.step_name,50),
	   'StepCommand'  = LEFT(S2.command,500),
       'ScheduleName' = left(ss.name,50),
       'Enabled'      = CASE (S.enabled)
                          WHEN 0 THEN 'No'
                          WHEN 1 THEN 'Yes'
                          ELSE '??'
                        END,
       'Frequency'    = CASE(ss.freq_type)
                          WHEN 1  THEN 'Once'
                          WHEN 4  THEN 'Daily'
                          WHEN 8  THEN (case when (ss.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),ss.freq_recurrence_factor) + ' Weeks'  else 'Weekly'  end)
                          WHEN 16 THEN (case when (ss.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),ss.freq_recurrence_factor) + ' Months' else 'Monthly' end)
                          WHEN 32 THEN 'Every ' + convert(varchar(3),ss.freq_recurrence_factor) + ' Months' -- RELATIVE
                          WHEN 64 THEN 'SQL Startup'
                          WHEN 128 THEN 'SQL Idle'
                          ELSE '??'
                        END,
       'Interval'    = CASE
                         WHEN (freq_type = 1)                       then 'One time only'
                         WHEN (freq_type = 4 and freq_interval = 1) then 'Every Day'
                         WHEN (freq_type = 4 and freq_interval > 1) then 'Every ' + convert(varchar(10),freq_interval) + ' Days'
                         WHEN (freq_type = 8) then (select 'Weekly Schedule' = D1+ D2+D3+D4+D5+D6+D7 
                                                       from (select ss.schedule_id,
                                                                     freq_interval, 
                                                                     'D1' = CASE WHEN (freq_interval & 1  <> 0) then 'Sun ' ELSE '' END,
                                                                     'D2' = CASE WHEN (freq_interval & 2  <> 0) then 'Mon '  ELSE '' END,
                                                                     'D3' = CASE WHEN (freq_interval & 4  <> 0) then 'Tue '  ELSE '' END,
                                                                     'D4' = CASE WHEN (freq_interval & 8  <> 0) then 'Wed '  ELSE '' END,
                                                                    'D5' = CASE WHEN (freq_interval & 16 <> 0) then 'Thu '  ELSE '' END,
                                                                     'D6' = CASE WHEN (freq_interval & 32 <> 0) then 'Fri '  ELSE '' END,
                                                                     'D7' = CASE WHEN (freq_interval & 64 <> 0) then 'Sat '  ELSE '' END
                                                                 from msdb..sysschedules ss
                                                                where freq_type = 8
                                                           ) as F
                                                       where schedule_id = sj.schedule_id
                                                    )
                         WHEN (freq_type = 16) then 'Day ' + convert(varchar(2),freq_interval) 
                         WHEN (freq_type = 32) then (select freq_rel + WDAY 
                                                        from (select ss.schedule_id,
                                                                     'freq_rel' = CASE(freq_relative_interval)
                                                                                    WHEN 1 then 'First'
                                                                                    WHEN 2 then 'Second'
                                                                                    WHEN 4 then 'Third'
                                                                                    WHEN 8 then 'Fourth'
                                                                                    WHEN 16 then 'Last'
                                                                                    ELSE '??'
                                                                                  END,
                                                                    'WDAY'     = CASE (freq_interval)
                                                                                    WHEN 1 then ' Sun'
                                                                                    WHEN 2 then ' Mon'
                                                                                    WHEN 3 then ' Tue'
                                                                                    WHEN 4 then ' Wed'
                                                                                    WHEN 5 then ' Thu'
                                                                                    WHEN 6 then ' Fri'
                                                                                    WHEN 7 then ' Sat'
                                                                                    WHEN 8 then ' Day'
                                                                                    WHEN 9 then ' Weekday'
                                                                                    WHEN 10 then ' Weekend'
                                                                                    ELSE '??'
                                                                                  END
                                                                from msdb..sysschedules ss
                                                                where ss.freq_type = 32
                                                             ) as WS 
                                                       where WS.schedule_id =ss.schedule_id
                                                       ) 
                       END,
       'Time' = CASE (freq_subday_type)
                        WHEN 1 then   left(stuff((stuff((replicate('0', 6 - len(Active_Start_Time)))+ convert(varchar(6),Active_Start_Time),3,0,':')),6,0,':'),8)
                        WHEN 2 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' seconds'
                        WHEN 4 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' minutes'
                        WHEN 8 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' hours'
                        ELSE '??'
                      END

       --'Next Run Time' = CASE SJ.next_run_date
       --                    WHEN 0 THEN cast('n/a' as char(10))
       --                    ELSE convert(char(10), convert(datetime, convert(char(8),SJ.next_run_date)),120)  + ' ' + left(stuff((stuff((replicate('0', 6 - len(next_run_time)))+ convert(varchar(6),next_run_time),3,0,':')),6,0,':'),8)
       --                  END
  
   from msdb.dbo.sysjobschedules SJ 
   join msdb.dbo.sysjobs         S  on S.job_id       = SJ.job_id
   join msdb.dbo.sysschedules    SS on ss.schedule_id = sj.schedule_id
   join msdb.dbo.sysjobsteps     S2 on S2.job_id = S.job_id
order by S.name



GO

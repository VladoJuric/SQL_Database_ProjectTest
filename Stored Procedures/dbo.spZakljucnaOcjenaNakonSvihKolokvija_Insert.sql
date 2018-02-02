SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spZakljucnaOcjenaNakonSvihKolokvija_Insert]
as
begin try
set nocount on
begin transaction
declare @danas date = getdate()
declare @min int=0
declare @max int=0

if (@danas > (select DatumIspita from RedIspita where PkAppDataIspit=(select PkAppDataIspit from AppDataIspit where TipIspit='Prvi Ispitni rok') AND Semestar=1) AND @danas < (select DatumIspita from RedIspita where PkAppDataIspit=(select PkAppDataIspit from AppDataIspit where TipIspit='Prvi Kolokvij') AND Semestar=2))
begin
	
	create table #PrviKolokvij1 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #PrviKolokvij1 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=1

	create table #DrugiKolokvij1 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #DrugiKolokvij1 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=2

	create table #PrviIspit1 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #PrviIspit1 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=3

	create table #ZavrsniKolokvij1 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #ZavrsniKolokvij1 select a.PkOsoba,a.PkPredmet,0,cast((a.Ocjena+b.Ocjena)/2 as decimal(2,1)) +0.5 from #PrviKolokvij1 a, #DrugiKolokvij1 b where a.PkOsoba=b.PkOsoba and a.PkPredmet=b.PkPredmet

	if not exists (select * from StudentPredmetZakljucno sz, #ZavrsniKolokvij1 zk where sz.PkOsoba=zk.PkOsoba and sz.PkPredmet=zk.PkPredmet and zk.Ocjena > sz.ZakljucnaOcjena)
	begin
		insert into StudentPredmetZakljucno (PkOsoba,PkPredmet,PkRedIspita,ZakljucnaOcjena) select PkOsoba,PkPredmet,PkRedIspita,Ocjena from #ZavrsniKolokvij1
		PRINT 'Unesene su zakljucne ocjene za kolokvije u prvom semestru'
	END

	if exists (select * from StudentPredmetZakljucno sz, #PrviIspit1 p where sz.PkOsoba=p.PkOsoba and sz.PkPredmet=p.PkPredmet and p.Ocjena > sz.ZakljucnaOcjena)
	begin
		create table #Tmp0 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
		insert into #Tmp0 select p.PkOsoba,p.PkPredmet,p.PkRedIspita,p.Ocjena from StudentPredmetZakljucno sz, #PrviIspit1 p where sz.PkOsoba=p.PkOsoba and sz.PkPredmet=p.PkPredmet and p.Ocjena > sz.ZakljucnaOcjena

		select @min=min(PkOsoba) from #Tmp0
		select @max=max(PkOsoba) from #Tmp0

		while(@min<=@max)
		begin
		
			update StudentPredmetZakljucno set ZakljucnaOcjena=(select Ocjena from #Tmp0 where PkOsoba=@min), PkRedIspita=3 where PkOsoba=@min

			select @min=@min+1
		end

		drop table #Tmp0
		PRINT 'Unesene su zakljucne ocjene za ispit u prvom semestru'
	end

	drop table #PrviKolokvij1
	drop table #DrugiKolokvij1
	drop table #ZavrsniKolokvij1
	drop table #PrviIspit1
END
else
	PRINT 'Pokrenite proceduru kada zavrse svi kolokviji i ispiti u prvom semestru'


if (@danas > (select DatumIspita from RedIspita where PkAppDataIspit=(select PkAppDataIspit from AppDataIspit where TipIspit='Prvi Ispitni rok') AND Semestar=2) AND @danas < (select DatumIspita from RedIspita where PkAppDataIspit=(select PkAppDataIspit from AppDataIspit where TipIspit='Dekanski rok') AND Semestar=2))
begin

	create table #PrviKolokvij2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #PrviKolokvij2 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=4

	create table #DrugiKolokvij2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #DrugiKolokvij2 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=5

	create table #PrviIspit2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #PrviIspit2 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=6

	create table #DrugiIspit2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #DrugiIspit2 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=7

	create table #TreciIspit2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #TreciIspit2 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=8

	create table #Dekanski2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #Dekanski2 select PkOsoba,PkPredmet,PkRedIspita,Ocjena from StudentPredmet where PkRedIspita=9

	create table #ZavrsniKolokvij2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
	insert into #ZavrsniKolokvij2 select a.PkOsoba,a.PkPredmet,0,cast((a.Ocjena+b.Ocjena)/2 as decimal(2,1)) +0.5 from #PrviKolokvij2 a, #DrugiKolokvij2 b where a.PkOsoba=b.PkOsoba and a.PkPredmet=b.PkPredmet

	if not exists (select * from StudentPredmetZakljucno sz, #ZavrsniKolokvij2 zk where sz.PkOsoba=zk.PkOsoba and sz.PkPredmet=zk.PkPredmet and zk.Ocjena > sz.ZakljucnaOcjena)
	begin
		insert into StudentPredmetZakljucno (PkOsoba,PkPredmet,PkRedIspita,ZakljucnaOcjena) select PkOsoba,PkPredmet,PkRedIspita,Ocjena from #ZavrsniKolokvij2
		PRINT 'Unesene su zakljucne ocjene za kolikvije u drugom semestru'
	END

	if exists (select * from StudentPredmetZakljucno sz, #PrviIspit2 p where sz.PkOsoba=p.PkOsoba and sz.PkPredmet=p.PkPredmet and p.Ocjena > sz.ZakljucnaOcjena)
	begin
		create table #Tmp1 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
		insert into #Tmp1 select p.PkOsoba,p.PkPredmet,p.RedIspita,p.Ocjena from StudentPredmetZakljucno sz, #PrviIspit2 p where sz.PkOsoba=p.PkOsoba and sz.PkPredmet=p.PkPredmet and p.Ocjena > sz.ZakljucnaOcjena

		select @min=min(PkOsoba) from #Tmp1
		select @max=max(PkOsoba) from #Tmp1

		while(@min<=@max)
		begin
		
			update StudentPredmetZakljucno set ZakljucnaOcjena=(select Ocjena from #Tmp1 where PkOsoba=@min), PkRedIspita=3 where PkOsoba=@min

			select @min=@min+1
		end

		drop table #Tmp1
		PRINT 'Unesene su zakljucne ocjene za prvi ispit u drugom semestru'
	end

	if exists (select * from StudentPredmetZakljucno sz, #DrugiIspit2 d where sz.PkOsoba=d.PkOsoba and sz.PkPredmet=d.PkPredmet and d.Ocjena > sz.ZakljucnaOcjena)
	begin
		create table #Tmp2 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
		insert into #Tmp2 select d.PkOsoba,d.PkPredmet,d.RedIspita,d.Ocjena from StudentPredmetZakljucno sz, #DrugiIspit2 d where sz.PkOsoba=d.PkOsoba and sz.PkPredmet=d.PkPredmet and d.Ocjena > sz.ZakljucnaOcjena

		select @min=min(PkOsoba) from #Tmp2
		select @max=max(PkOsoba) from #Tmp2

		while(@min<=@max)
		begin
		
			update StudentPredmetZakljucno set ZakljucnaOcjena=(select Ocjena from #Tmp2 where PkOsoba=@min), PkRedIspita=4 where PkOsoba=@min

			select @min=@min+1
		end

		drop table #Tmp2
		PRINT 'Unesene su zakljucne ocjene za drugi ispit u drugom semestru'
	end

	if exists (select * from StudentPredmetZakljucno sz, #TreciIspit2 t where sz.PkOsoba=t.PkOsoba and sz.PkPredmet=t.PkPredmet and t.Ocjena > sz.ZakljucnaOcjena)
	begin
		create table #Tmp3 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
		insert into #Tmp3 select t.PkOsoba,t.PkPredmet,t.RedIspita,t.Ocjena from StudentPredmetZakljucno sz, #TreciIspit2 t where sz.PkOsoba=t.PkOsoba and sz.PkPredmet=t.PkPredmet and t.Ocjena > sz.ZakljucnaOcjena
		
		select @min=min(PkOsoba) from #Tmp3
		select @max=max(PkOsoba) from #Tmp3

		while(@min<=@max)
		begin
		
			update StudentPredmetZakljucno set ZakljucnaOcjena=(select Ocjena from #Tmp3 where PkOsoba=@min), PkRedIspita=5 where PkOsoba=@min

			select @min=@min+1
		end

		drop table #Tmp3
		PRINT 'Unesene su zakljucne ocjene za treci ispit u drugom semestru'
	end

	if exists (select * from StudentPredmetZakljucno sz, #Dekanski2 r where sz.PkOsoba=r.PkOsoba and sz.PkPredmet=r.PkPredmet and r.Ocjena > sz.ZakljucnaOcjena)
	begin
		create table #Tmp4 (PkOsoba int,PkPredmet int,PkRedIspita int,Ocjena smallint)
		insert into #Tmp4 select r.PkOsoba,r.PkPredmet,r.RedIspita,r.Ocjena from StudentPredmetZakljucno sz, #Dekanski2 r where sz.PkOsoba=r.PkOsoba and sz.PkPredmet=r.PkPredmet and r.Ocjena > sz.ZakljucnaOcjena
		
		SELECT @min=min(PkOsoba) from #Tmp4
		select @max=max(PkOsoba) from #Tmp4

		while(@min<=@max)
		begin
		
			update StudentPredmetZakljucno set ZakljucnaOcjena=(select Ocjena from #Tmp4 where PkOsoba=@min), PkRedIspita=6 where PkOsoba=@min

			select @min=@min+1
		end

		drop table #Tmp4
		PRINT 'Unesene su zakljucne ocjene za dekanski ispit u drugom semestru'
	end

	drop table #PrviKolokvij2
	drop table #DrugiKolokvij2
	drop table #ZavrsniKolokvij2
	drop table #PrviIspit2
	drop table #DrugiIspit2
	drop table #TreciIspit2
	drop table #Dekanski2

END
else
	PRINT 'Pokrenite proceduru kada zavrse svi kolokviji i prvi ispitni rok u drugom semestru'

end try
begin catch
	execute dbo.GetErrorInfo;
	if @@TRANCOUNT > 0
		rollback transaction;
end catch;
if @@TRANCOUNT > 0
	commit transaction;
GO

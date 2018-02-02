SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[GetErrorInfo]
as
select
	--PROCEDURA ZA ISPIS GRESKE 
	ERROR_NUMBER() as ErrorNumber,
	ERROR_SEVERITY() as ErrorSeverity,
	ERROR_STATE() as ErrorState,
	ERROR_PROCEDURE() as ErrorProcedure,
	ERROR_LINE() as ErrorLine,
	ERROR_MESSAGE() as ErrorMessage;
GO

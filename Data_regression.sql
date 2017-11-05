


--Dental Research project 2017
--Author: Mo Villagran
--affordability index
--best value dentist
--prediction of cost
--paid/billed ratios of CDT by ST
--etc.

--testing with data in State onlyM

--Data from Company 2012 Dental
drop table [Proband_Mo].[dbo].[R_testing_CompanyYear_State];

WITH POP AS (
SELECT
[ZIP3]
,[ST]
,MSAcode
,CountyFIPS
,FIPS_Code
,StateFIPS
,[URBAN_RURAL_IND]
,SUM(CAST([Population] AS int)) AS TOT_POP 
     
FROM [UCR_FH].[dbo].[refMR_ZIP_2017] Z 
--U:\Health\Clients_Active\JEF.DentalWorkForOtherOffices\932DCG17-96_UCR_Factor\2_Doc\HCG Area Code Sets tab: Export to text
--select [refMR_ZIP] to export, remember to change directory for export

group by 
[ZIP3]
,[ST]
,MSAcode
,CountyFIPS
,FIPS_Code
,StateFIPS
,[URBAN_RURAL_IND]
--order by ZIP3
)
SELECT 
[SequenceNumber]
,[ClaimID]
,[LineNum]
,[ContractID]
,[BenefitCode]
,[MemberID]
,[DOB]
,[Gender]
,[FromDate]
,[PaidDate]
,[CDT]
--,[srcPOS]
,[POS]
--,[srcSpecialty]
,[Specialty]
,(CASE WHEN [Specialty] in ('01', 'X0') THEN 'Dentist'
       WHEN [Specialty] = '19' THEN 'Orthodontist'
	   Else 'Other' END) AS Specialty_dentist
,[ProviderID]
,[ProviderZIP]
,[Billed]
,[Allowed]
,[Paid]

,[Paid]/[Allowed] as Paid_Allowed_Ratio
,[Allowed]/[Billed] as Allowed_Billed_Ratio

,[COB]
,[Copay]
,[Coinsurance]
,[Deductible]
,[PatientPay]
,[Units]
,[OON]

,(CASE WHEN [OON] = 'N' THEN 0 ElSE 1 END) As OON_Stateag  --1 means in out of network


--,[srcLOB]
,[LOB]

/*LOB:  ADV COM IND SUP UNK  */
,(CASE WHEN [LOB] = 'ADV' THEN 1 ELSE 0 END) As LOB_ADV
,(CASE WHEN [LOB] = 'COM' THEN 1 ELSE 0 END) As LOB_COM
,(CASE WHEN [LOB] = 'IND' THEN 1 ELSE 0 END) As LOB_IND
,(CASE WHEN [LOB] = 'SUP' THEN 1 ELSE 0 END) As LOB_SUP
,(CASE WHEN [LOB] = 'UNK' THEN 1 ELSE 0 END) As LOB_UNK

--,[srcProduct]
,[Product]

/*CMM EPO PPO UNK*/
,(CASE WHEN [Product] = 'CMM' THEN 1 ELSE 0 END) AS [Product_CMM]
,(CASE WHEN [Product] = 'EPO' THEN 1 ELSE 0 END) AS [Product_EPO]
,(CASE WHEN [Product] = 'PPO' THEN 1 ELSE 0 END) AS [Product_PPO]
,(CASE WHEN [Product] = 'UNK' THEN 1 ELSE 0 END) AS [Product_UNK]

,[GroupID]
,[YearMo]
,[PaidMo]
,[State]
,[MSA]
,[ExclusionCode]
,[PartialYearGroup]
,[ResearcherExclusionCode]
,[DCGIndicator]
,[DepCode]
,[MemberAgeBand]
,[GroupSizeCategory]

,(CASE WHEN [GroupSizeCategory] = '100+' THEN 1 ELSE 0 END) AS [GroupSizeCategory_100Above_Stateag]

,[CapitationIndicator]

,(CASE WHEN [CapitationIndicator] = 'N' THEN 0 ELSE 1 END ) As [Capitation_Stateag]

,[DCG_Category]
,[DCG_Class]
,[MR_Units_Days]
,[MR_Procs]
,[MR_Units_Days_PatientPay]
,[MR_Procs_PatientPay]
,[MR_Billed]
,[MR_Allowed]
,[MR_Paid]
,[MR_Copay]
,[MR_Coinsurance]
,[MR_Deductible]
,[MR_PatientPay]
--,[ContributorId]
,ZIP3
,CountyFIPS
,FIPS_Code
,StateFIPS
,[URBAN_RURAL_IND]
,PERCENTILE_CONT ( 0.25 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_25th'
,PERCENTILE_CONT ( 0.30 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_30th'
,PERCENTILE_CONT ( 0.40 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_40th'
,PERCENTILE_CONT ( 0.50 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_50th'
,PERCENTILE_CONT ( 0.60 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_60th'
,PERCENTILE_CONT ( 0.70 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_70th'
,PERCENTILE_CONT ( 0.75 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_75th'
,PERCENTILE_CONT ( 0.80 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_80th'
,PERCENTILE_CONT ( 0.85 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_85th'
,PERCENTILE_CONT ( 0.90 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_90th'
,PERCENTILE_CONT ( 0.95 ) WITHIN GROUP ( ORDER BY billed ) OVER ( PARTITION by CDT ) as  'Company_95th'


into [Proband_Mo].[dbo].[R_testing_CompanyYear_State] 
FROM [Dental].[dbo].[OUTDENTALCLAIMS_Year] AS A
left join POP P
on left(A.ProviderZIP,3) = P.ZIP3  --some column is missing so we have duplicate totpop>> investigate

where A.[State] = 'State' and Units > 0 and Billed > 0 and Allowed > 0 and Paid > 0
and left(PaidMo,4) = 'Year' --contain just one year of claim 



select top 1000 * from [Proband_Mo].[dbo].[R_testing_CompanyYear_State] 


--Adding Dentist ratios from Joanne's data
select * from Proband_Mo.dbo.State_Dentist_Ratio

drop table [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_ratio];

--Combine ratio to Company State table
drop table [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_ratio];

Select 
A.*
,[FIPS]
,[County]
,CAST([# Dentists] as Int) AS NumOfDentists
,CAST([Dentist Rate] AS Stateoat)AS DentistRate
,CAST(left([Dentist Ratio], len([Dentist Ratio])-3) as int) AS DentistRatio
,CAST([Z-Score] as Stateoat) AS Zscore

into [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_ratio]
From [Proband_Mo].[dbo].[R_testing_CompanyYear_State] A
left join Proband_Mo.dbo.State_Dentist_Ratio B
on A.FIPS_Code = B.FIPS
where FIPS is not null and BIlled is not null

select * from Proband_Mo.dbo.[R_testing_CompanyYear_State_dentist_ratio]

--Now only use the top CDT codes for Stat analysis

drop table [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110]

select * 

into [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110]
from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_ratio]
where CDT = 'D1110' and Specialty_dentist = 'Dentist' --adult cleaning

select * from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110]

--------------------------R code begins here------------------------------------------------------

use Proband_Mo;
--source table for analysis here


EXEC sp_execute_external_script
  @language =N'R',
  --R script below
  @script=N'OutputDataSet<-InputDataSet;
  Billed <-OutputDataSet$Billed ',
  @input_data_1 =N'select top 10
	  [Billed]
     
	   from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110];'
with result sets ((Billed Stateoat not null));

--table I want to test here in R

drop table [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test]

select
[Billed]
,[Allowed]
,[Paid]
,[Paid_Allowed_Ratio]
,[Allowed_Billed_Ratio]
,[OON_Stateag]
,[LOB_ADV]
,[LOB_COM]
,[LOB_IND]
,[LOB_SUP]
,[LOB_UNK]
,[Product_CMM]
,[Product_EPO]
,[Product_PPO]
,[Product_UNK]
,[GroupSizeCategory_100Above_Stateag]
,[Capitation_Stateag]
,[Company_25th]
,[Company_30th]
,[Company_40th]
,[Company_50th]
,[Company_60th]
,[Company_70th]
,[Company_75th]
,[Company_80th]
,[Company_85th]
,[Company_90th]
,[Company_95th]
,[FIPS]
,[County]
,CAST([NumOfDentists] as Stateoat) as [NumOfDentists]
,CAST([DentistRate] as Stateoat) as [DentistRate]
,CAST([DentistRatio] as Stateoat) as [DentistRatio]
,CAST([Zscore] as Stateoat) as [Zscore]
into [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test]
from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110]
where LOB_COM = 1 and NumOfDentists is not null and [Paid_Allowed_Ratio] < 0.99
and [Allowed_Billed_Ratio] < 0.99 --anything that is = or > than 1 makes no sense and there are many 0.99 values


select * from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test]

select distinct [DentistRate]  from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test]


--Create a regression model when it is ready for production for all specialty, state and CDT

DROP PROCEDURE IF EXISTS generate_linear_model;
GO
CREATE PROCEDURE generate_linear_model
AS
BEGIN
    EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'y<-data.frame(D1110);

	    mymodel <- glm(formula = y$Allowed_Billed_Ratio~ y$Paid + y$OON_Stateag + y$GroupSizeCategory_100Above_Stateag + y$LOB_COM, family="binomial", data=y);
		result<-Summary(mymodel);'
		
    , @input_data_1 = N'select * from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test];'
    , @input_data_1_name = N'D1110'
    , @output_data_1_name = N'trained_model'
    WITH RESULT SETS ((model varbinary(max)));
END;
GO


drop table Dentist_models;
--create table to store results
CREATE TABLE Dentist_models (
    model_name varchar(30) not null default('default model') primary key,
    model varbinary(max) not null);


INSERT INTO Dentist_models (model)
EXEC generate_linear_model;



--see result here

DECLARE @model varbinary(max), @modelname varchar(30)
EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
	
		y<-data.frame(D1110);
        mymodel <- glm(formula = y$Allowed_Billed_Ratio~ y$Paid + y$OON_Stateag + y$Product_CMM + y$Product_EPO + y$Product_PPO + y$Product_UNK + y$GroupSizeCategory_100Above_Stateag + y$NumOfDentists + y$DentistRate, family="binomial", data=y)
        modelbin <- serialize(mymodel, NULL);
		result <- summary(mymodel);
        OutputDataSet <- data.frame(coefficients(mymodel));'

    , @input_data_1 = N'select * from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test];'
    , @input_data_1_name = N'D1110'
    , @params = N'@modelbin varbinary(max) OUTPUT'
    , @modelbin = @model OUTPUT
    WITH RESULT SETS (( [Coefficients] Stateoat not null));

-- Save the generated model
INSERT INTO [dbo].[Dentist_models] (model_name, model)
VALUES (' latest model', @model)

--create table and graphs here










TRUNCATE TABLE	[Database1].dbo.Example




INSERT INTO Scorecard.[dbo].Example
SELECT  DISTINCT  Masterkey
FROM	[AggregateDatabase1].dbo.[Example_Table]
WHERE	IDOrganization = 279
AND Masterkey LIKE '292%'





-- Getting patients first, last, and DOB


UPDATE Example
SET	[Patient's First Name]	= Pers..PsnFirst,	[Patient's Late Name]	=  Pers.PsnLaSt,	[Patient's Date of Birth]	=  Pers.Psnous,	[Client Name]	= Pers.PcPPracticeName
FROM [AggregateDatabase1].dbo.[Example_Table] Pers
JOIN  Scorecard.Example  samp
ON  Pers.MasterKey	=   samp.MRN
WHERE Pers.IDOrganization = Pers.IDMasterOrganization
AND  Pers.Idstatus = 1




--  getting most recent phone number

UPDATE  Example
SET	[Patient's  Phone  Number]	=  replace(replace(replace(replace(replace(replace(replace(replace(LTRIM(RTRIM(A.Phone)),'-',''),'(',''),')',''), ' ' ,''), '/' ,''),'x',''),'*',''),'calls','')
FROM (
 
SELECT  Phone [MasterKey],Phone.Phone,Phone.DateUpdated, ROW_NUMBER()  OVER (PARTITION BY Phone.MasterKey ORDER BY Phone.DateUpdated DESC) RN
FROM  [AggregateDatabase1].dbo.[Phone_Table]   Phone 
	INNER  JOIN  Scorecard.Example samp
ON Phone.Masterkey = samp.MRN
WHERE  PhoneType  in ('CELL','HOME') 
and  ISNULL ([Phone],'')  <> ''
and phone not  like  '%[a-z]%'
and  replace(replace(replace(replace(replace(replace(replace(replace(LTRIM(RTRIM(Phone.Phone)),'-',''),'(',''),')',''), ' ' ,''), '/' ,''),'x',''),'*',''),'calls','') NOT LIKE 'e%'
and lenreplace(replace(replace(replace(replace(replace(replace(replace(LTRIM(RTRIM(Phone.Phone)),'-',''),'(',''),')',''), ' ' ,''), '/' ,''),'x',''),'*',''),'calls','') = 10
) A

join [AggregateDatabase1].dbo.[Person_Table] j 	on a.MasterKey = j.MasterKey
join [AggregateDatabase1].dbo.[Master_Patient_Index_Table]  d  on  j.IDOrganization =  d.IDOrganization  END J.IDPerson = d.IDPerson 
INNER JOIN Scorecard.dbo.example Outp
ON A.MasterKey = OutP.MRN
WHERE  RN = 1





--  formats  phone  number

UPDATE  Example 
SET [Patient's   Phone  Number] =  SUBSTRING([Patient's  Phone  Number], 	1, 	3) +  '-' +
							SUBSTRING{[Patient's  Phone  Number],  4,	3) + '-' +
							SUBSTRING([Patient's  Phone  Number],  7,	4)















SELECT r.ProtCode
						,SUM(CASE  WHEN  R.Recommendation  LIKE	'%current'  THEN 1
								ELSE  0
							END)	[Met]	--Numerator
						,SUM(CASE  WHEN  R.Recommendation  LIKE	'%invalid' THEN 1
								ELSE  0
							END)	[Not Met]
						,SUM(CASE  WHEN  R.Recommendation  LIKE	'%incl'  THEN 1
								ELSE  0
							END)	[Denominator]
						,SUM(CASE  WHEN  R.Recommendation  LIKE	'%excl'  THEN 1
								ELSE  0
							END)	[Exclusion]
						,SUM(CASE  WHEN  R.Recommendation  LIKE	'%exception'  THEN 1
								ELSE  0
							END)	[Exception]
						,
					CONVERT(Decimal(20,1),
				  (CONVERT{Decimal(20,1), SUM(CASE WHEN R.Recommendation LIKE '%current' THEN 1  ELSE	0  END)*100)  )
						/
(SUM(CASE  WHEN  (R.Recommendation  LIKE   '%incl' THEN	1  ELSE	0  END)-SUM(CASE  WHEN  R.Recommendation  LIKE  '%exception'  THEN 1  ELSE	0  END) )
)	[Performance  Rate  %]


FROM 	[Example],[dbo].(Recommendations)  r WITH(NOLOCK)

				WHERE 	(R.Recommendation  LIKE  '%current'
						OR  R.Recommendation  LIKE  '%Excl' 
						OR  R.Recommendation  LIKE  '%Incl'
						OR  R.Recommendation  LIKE  '%Invalid'
						OR  R.Recommendation  LIKE  '%Exception')
GROUP BY r.ProtCode
ORDER BY 1

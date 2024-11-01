-- Clear the Example table
TRUNCATE TABLE [Database1].dbo.Example;

-- Insert distinct MasterKey values
INSERT INTO Scorecard.dbo.Example (MasterKey)
SELECT DISTINCT MasterKey
FROM [AggregateDatabase1].dbo.Example_Table
WHERE IDOrganization = 279
  AND MasterKey LIKE '292%';

-- Update Example table with patient details
UPDATE samp
SET 
    [Patient's First Name] = Pers.PsnFirst,
    [Patient's Last Name] = Pers.PsnLast,
    [Patient's Date of Birth] = Pers.PsnDOB,
    [Client Name] = Pers.PcPPracticeName
FROM Scorecard.dbo.Example samp
JOIN [AggregateDatabase1].dbo.Example_Table Pers
    ON Pers.MasterKey = samp.MRN
WHERE Pers.IDOrganization = Pers.IDMasterOrganization
  AND Pers.Idstatus = 1;

-- Update Example table with the most recent phone number
UPDATE samp
SET [Patient's Phone Number] = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    LTRIM(RTRIM(A.Phone)), '-', ''), '(', ''), ')', ''), ' ', ''), '/', ''), 'x', ''), '*', ''), 'calls', '')
FROM (
    SELECT 
        Phone.MasterKey,
        Phone.Phone,
        Phone.DateUpdated,
        ROW_NUMBER() OVER (PARTITION BY Phone.MasterKey ORDER BY Phone.DateUpdated DESC) AS RN
    FROM [AggregateDatabase1].dbo.Phone_Table Phone
    JOIN Scorecard.dbo.Example samp ON Phone.MasterKey = samp.MRN
    WHERE PhoneType IN ('CELL', 'HOME')
      AND ISNULL(Phone.Phone, '') <> ''
      AND Phone.Phone NOT LIKE '%[a-z]%'
      AND LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
          LTRIM(RTRIM(Phone.Phone)), '-', ''), '(', ''), ')', ''), ' ', ''), '/', ''), 'x', ''), '*', ''), 'calls', '')) = 10
) A
JOIN [AggregateDatabase1].dbo.Person_Table j ON A.MasterKey = j.MasterKey
JOIN [AggregateDatabase1].dbo.Master_Patient_Index_Table d
    ON j.IDOrganization = d.IDOrganization
    AND j.IDPerson = d.IDPerson
JOIN Scorecard.dbo.Example Outp ON A.MasterKey = Outp.MRN
WHERE RN = 1;

-- Format the phone number in Example table
UPDATE Example
SET [Patient's Phone Number] = 
    SUBSTRING([Patient's Phone Number], 1, 3) + '-' +
    SUBSTRING([Patient's Phone Number], 4, 3) + '-' +
    SUBSTRING([Patient's Phone Number], 7, 4);

-- Calculate and display performance metrics
SELECT 
    r.ProtCode,
    SUM(CASE WHEN R.Recommendation LIKE '%current' THEN 1 ELSE 0 END) AS [Met], -- Numerator
    SUM(CASE WHEN R.Recommendation LIKE '%invalid' THEN 1 ELSE 0 END) AS [Not Met],
    SUM(CASE WHEN R.Recommendation LIKE '%incl' THEN 1 ELSE 0 END) AS [Denominator],
    SUM(CASE WHEN R.Recommendation LIKE '%excl' THEN 1 ELSE 0 END) AS [Exclusion],
    SUM(CASE WHEN R.Recommendation LIKE '%exception' THEN 1 ELSE 0 END) AS [Exception],
    CONVERT(DECIMAL(20, 1),
        (CONVERT(DECIMAL(20, 1), SUM(CASE WHEN R.Recommendation LIKE '%current' THEN 1 ELSE 0 END) * 100.0) /
        (SUM(CASE WHEN R.Recommendation LIKE '%incl' THEN 1 ELSE 0 END) - 
        SUM(CASE WHEN R.Recommendation LIKE '%exception' THEN 1 ELSE 0 END))
    ) AS [Performance Rate %]
FROM [dbo].[Recommendations] r WITH (NOLOCK)
WHERE R.Recommendation LIKE '%current'
   OR R.Recommendation LIKE '%Excl'
   OR R.Recommendation LIKE '%Incl'
   OR R.Recommendation LIKE '%Invalid'
   OR R.Recommendation LIKE '%Exception'
GROUP BY r.ProtCode
ORDER BY r.ProtCode;

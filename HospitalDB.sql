CREATE DATABASE ZimenaHospital  
USE ZimenaHospital 
GO


CREATE TABLE Patients (
PatientID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
PatientFirstName NVARCHAR(50) NOT NULL, 
PatientMiddleName NVARCHAR(50) NULL,
PatientLastName NVARCHAR(50) NOT NULL, 
PatientTelephoneNumber NVARCHAR(20) NULL, 
PatientDOB DATE NOT NULL, 
Address NVARCHAR (50) NOT NULL,
Insurance NVARCHAR(15) NULL,
PatientEmailAddress NVARCHAR(100) UNIQUE NOT NULL CHECK (PatientEmailAddress  LIKE '%_@_%._%'), 
DateLeft Date NULL,
PasswordHash VARBINARY(65) NOT NULL,
Salt UNIQUEIDENTIFIER);



CREATE TABLE Departments(
DepartmentID TINYINT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
DepartmentName NVARCHAR(50) NOT NULL);



CREATE TABLE Doctors( 
DoctorID TINYINT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
DoctorFirstName NVARCHAR(50) NOT NULL, 
DoctorLastName NVARCHAR(50) NOT NULL, 
DoctorTelPhone NVARCHAR(50) NOT NULL,
Specialist NVARCHAR(50) NOT NULL, 
DoctorAvailability NVARCHAR(7) NULL,
DepartmentID TINYINT NOT NULL, 
CONSTRAINT fk_Doctors_Departments FOREIGN KEY(DepartmentID) REFERENCES Departments(DepartmentID)); 



CREATE TABLE Current_Appointments( 
AppointmentID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
AppointmentDate DATE NOT NULL, 
AppointmentTime TIME NOT NULL,
Status NVARCHAR(20) NOT NULL CHECK(Status IN ('pending', 'cancelled', 'available')),
PatientID INT NOT NULL,
DoctorID TINYINT NOT NULL,
CONSTRAINT fk_Current_Appointments_Patients FOREIGN KEY(PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
CONSTRAINT fk_Current_Appointments_Doctors FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID))



CREATE TABLE PastAppointments( 
PastAppointmentID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
Date DATE  NOT NULL, 
Status NVARCHAR(20) NOT NULL,
FeedBack NVARCHAR(50) NULL,
DoctorID TINYINT NOT NULL,
CONSTRAINT fk_PastAppointments_Doctors FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID);



CREATE TABLE PatientMedicalRecords( 
MedicalRecordID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
Diagnoses NVARCHAR(50) NULL , 
Allergies NVARCHAR(50) NULL, 
PatientID INT NOT NULL, 
PastAppointmentID INT NULL,
CONSTRAINT fk_PatientMedicalRecords_Patients FOREIGN KEY(patientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
CONSTRAINT fk_PatientMedicalRecords_PastAppointments FOREIGN KEY(PastAppointmentID) REFERENCES PastAppointments(PastAppointmentID))



CREATE TABLE Prescribe_Medication( 
PrescribeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
MedicalRecordID INT NOT NULL,
Medicine NVARCHAR(50) NOT NULL,
CONSTRAINT fk_Prescribe_Medication_PateintMedicalRecords FOREIGN KEY(MedicalRecordID) REFERENCES PatientMedicalRecords(MedicalRecordID))



--create stored procedure for patients table
CREATE PROCEDURE uspAddPatient 
@PatientFirstName NVARCHAR(50), 
@PatientMiddleName NVARCHAR(50),
@PatientLastName NVARCHAR(50), 
@PatientTelephoneNumber NVARCHAR(20),
@PatientDOB DATE, 
@Address NVARCHAR(50),
@Insurance NVARCHAR(10),
@EmailAddress NVARCHAR(100),
@DateLeft Date,
@Password NVARCHAR(60)
AS 
BEGIN TRANSACTION 
BEGIN TRY
DECLARE @Salt UNIQUEIDENTIFIER = NEWID();
INSERT INTO Patients (
PatientFirstName, 
PatientMiddleName, 
PatientLastName,
PatientTelephoneNumber,
PatientDOB,
Address,
Insurance, 
PatientEmailAddress,
DateLeft,
PasswordHash, 
Salt)
VALUES (
@PatientFirstName,
@PatientMiddleName,
@PatientLastName,
@PatientTelephoneNumber, 
@PatientDOB,
@Address,
@Insurance,
@EmailAddress, 
@DateLeft,
HASHBYTES('SHA2_512', @Password + CAST(@Salt AS NVARCHAR(40))),
@Salt);
COMMIT TRANSACTION
END TRY

BEGIN CATCH
--Looks like there was an error!
IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION
DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
SELECT @ErrMsg = ERROR_MESSAGE(),
@ErrSeverity = ERROR_SEVERITY()
RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH;

EXEC uspAddPatient 
@PatientFirstName = 'Cody', 
@PatientMiddleName = NULL,
@PatientLastName = 'Cameron',
@PatientTelephoneNumber = '077112233012', 
@PatientDOB = '1960-04-13',
@Address = 'salford 12',
@Insurance = 'TA1212',
@EmailAddress = 'codycameron_@_gmail.com', 
@DateLeft = NULL,
@Password = 'password1812'



--insert into Departments table using TCL 
BEGIN TRANSACTION 
BEGIN TRY 
	--declare variable
	DECLARE @DepartmentName NVARCHAR(50) = 'Neurology_Unit';
	--insert values into Departments table
	INSERT INTO Departments(DepartmentName) 
	VALUES (@DepartmentName); 
	COMMIT TRANSACTION 
 END TRY 

 BEGIN CATCH
	-- Catch error if unsuccessful 
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION; 
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
	SELECT 
	@ErrMsg = ERROR_MESSAGE(), 
	@ErrSeverity = ERROR_SEVERITY()
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;



--insert into Doctors table using TCL
BEGIN TRANSACTION 
BEGIN TRY 
	--declare variables
	DECLARE @DoctorFirstName NVARCHAR(50) = 'Teddy';
	DECLARE @DoctorLastName NVARCHAR(50) = 'Namukisa';
	DECLARE @DoctorTelPhone NVARCHAR(50) = '01612117318';
	DECLARE @Specialist NVARCHAR(50) = 'Neurologist';
	DECLARE @DoctorAvailability NVARCHAR(7) = 'YES';
	DECLARE @DepartmentID TINYINT = 4;
	--insert values into Doctors table
	INSERT INTO Doctors(DoctorFirstName, DoctorLastName, DoctorTelPhone, Specialist, DoctorAvailability, DepartmentID) 
	VALUES (@DoctorFirstName, @DoctorLastName, @DoctorTelPhone, @Specialist, @DoctorAvailability, @DepartmentID); 
	COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
	-- Catch error if unsuccessful 
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION; 
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
	SELECT 
	@ErrMsg = ERROR_MESSAGE(), 
	@ErrSeverity = ERROR_SEVERITY();
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH; 



--insert into Current_Appointments table using TCL
BEGIN TRANSACTION 
BEGIN TRY 
	--declare variables
	DECLARE @AppointmentDate DATE = '2024-04-11';
	DECLARE @AppointmentTime TIME = '15:00:00';
	DECLARE @Status NVARCHAR(20) = 'pending';
	DECLARE @PatientID INT = 12;
	DECLARE @DoctorID TINYINT = 6;
	--insert values into Current_Appointment 
	INSERT INTO Current_Appointments(AppointmentDate, AppointmentTime, Status, PatientID, DoctorID) 
	VALUES (@AppointmentDate, @AppointmentTime, @Status, @PatientID, @DoctorID); 
	COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
	-- Catch error if unsuccessful 
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION; 
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
	SELECT 
	@ErrMsg = ERROR_MESSAGE(), 
	@ErrSeverity = ERROR_SEVERITY();
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH; 



 --insert into PastAppointments table using TCL
BEGIN TRANSACTION 
BEGIN TRY 
	--declare variables
	DECLARE @Date DATE = '2024-02-17'
	DECLARE @Status NVARCHAR(20) = 'completed'
	DECLARE @FeedBack NVARCHAR(50) = NULL
	DECLARE @DoctorID TINYINT = 
	--insert values into PastAppointnment
	INSERT INTO PastAppointments(Date, Status, FeedBack, DoctorID) 
	VALUES (@Date, @Status, @FeedBack, @DoctorID); 
	COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
	-- Catch error if unsuccessful 
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION; 
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
	SELECT 
	@ErrMsg = ERROR_MESSAGE(), 
	@ErrSeverity = ERROR_SEVERITY();
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH; 



--insert into PatientMedicalRecords table using TCL
BEGIN TRANSACTION 
BEGIN TRY 
	--declare variables
	DECLARE @Diagnoses NVARCHAR(50) = 'STOMACH_FLU';
	DECLARE @Allergies NVARCHAR(50) = NULL;
	DECLARE @PatientID INT = 12
	DECLARE @PastAppointmentID INT = 11
	--insert values into PastAppointnment
	INSERT INTO PatientMedicalRecords(Diagnoses,Allergies, PatientID, PastAppointmentID) 
	VALUES (@Diagnoses , @Allergies, @PatientID, @PastAppointmentID); 
	COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
	-- Catch error if unsuccessful 
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION; 
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
	SELECT 
	@ErrMsg = ERROR_MESSAGE(), 
	@ErrSeverity = ERROR_SEVERITY();
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH; 



--insert into Prescribe_Medication  table using TCL
BEGIN TRANSACTION 
BEGIN TRY 
	--declare variables
	DECLARE @MedicalRecordID INT = 19
	DECLARE @Medicine NVARCHAR(60) = 'Mesalamine'
	--insert values into Prescribe_Medication
	INSERT INTO  Prescribe_Medication(MedicalRecordID, Medicine) 
	VALUES (@MedicalRecordID , @Medicine); 
	COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
	-- Catch error if unsuccessful 
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION; 
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
	SELECT 
	@ErrMsg = ERROR_MESSAGE(), 
	@ErrSeverity = ERROR_SEVERITY();
	RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;

SELECT * FROM Patients
SELECT * FROM Current_Appointments
SELECT * FROM Departments
SELECT * FROM Doctors
SELECT * FROM PatientMedicalRecords
SELECT * FROM PastAppointments
SELECT * FROM Prescribe_Medication



--Part2:
--Question 2:  Add the constraint to check that the appointment date is not in the past.
ALTER TABLE Current_Appointments
ADD CONSTRAINT chk_AppointmentDateNotInPast 
CHECK (AppointmentDate >= CAST(GETDATE() AS DATE));



--Question 3: List all the patients with older than 40 and have Cancer in diagnosis.
SELECT pa.PatientFirstName, pa.PatientMiddleName, pa.PatientLastName, pa.PatientDOB, pmr.Diagnoses 
FROM Patients AS pa INNER JOIN PatientMedicalRecords AS pmr 
ON pa.PatientID=pmr.PatientID 
WHERE pmr.Diagnoses LIKE '%CANCER%' AND DATEDIFF(Year, pa.PatientDOB, GETDATE()) >= 40



--Question 4: The hospital also requires stored procedures or user-defined functions to do the following things
--a) Search the database of the hospital for matching character strings by name of medicine. Results should be sorted with most recent medicine prescribed date first. 
--creat a function for the recent prescribe medicine 
CREATE FUNCTION dbo.fn_RecentPrescibeMedicine (@MedicineName NVARCHAR(60))
RETURNS TABLE 
AS 
RETURN
	(
	SELECT pmr.PatientID, pm.Medicine, p.Date AS RecentPrescribeDate
	FROM PastAppointments AS p 
		INNER JOIN PatientMedicalRecords AS pmr 
		ON p.PastAppointmentID = pmr.PastAppointmentID 
		INNER JOIN Prescribe_Medication AS pm 
		ON pmr.MedicalRecordID = pm.MedicalRecordID 
	WHERE pm.Medicine LIKE '%' + @MedicineName + '%'
);

--executing the function 
SELECT * FROM dbo.fn_RecentPrescibeMedicine('Faslodex')
ORDER BY RecentPrescribeDate DESC;



--b) Return a full list of diagnosis and allergies for a specific patient who has an appointment today (i.e., the system date when the query is run)
--create a function for diagnoses and allergies for a specific patient
CREATE FUNCTION dbo.fn_specificpatient (@patientid INT) 
RETURNS TABLE
AS 
RETURN( 
	SELECT (pa.PatientFirstName + ' ' + ISNULL(pa.PatientMiddleName, '') + ' ' + pa.PatientLastName) AS FullName, 
		pmr.Diagnoses, pmr.Allergies, AppointmentDate 
	FROM Current_Appointments AS ca INNER JOIN Patients AS pa 
		ON ca.PatientID=@PatientID INNER JOIN PatientMedicalRecords AS pmr 
		ON @PatientID=pmr.PatientID
	WHERE pa.PatientID = @patientid
)

--executing the function
SELECT * 
FROM dbo.fn_specificpatient(1)
WHERE AppointmentDate = CAST(GETDATE() AS DATE) 



--c) Update the details for an existing doctor 
CREATE PROCEDURE dbo.usp_DoctorUpdate 
@DoctorID TINYINT,
@DoctorTelPhone NVARCHAR(50),
@DoctorAvailability NVARCHAR(7)
AS
BEGIN
BEGIN TRANSACTION;
BEGIN TRY 
UPDATE Doctors 
SET DoctorTelPhone= @DoctorTelPhone, 
		DoctorAvailability = @DoctorAvailability
WHERE DoctorID = @DoctorID;

COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
-- Catch error if unsuccessful 
IF @@TRANCOUNT > 0 
ROLLBACK TRANSACTION; 
DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
SELECT 
@ErrMsg = ERROR_MESSAGE(), 
@ErrSeverity = ERROR_SEVERITY();
RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
END

--Execute the created procedure 
EXEC dbo.usp_DoctorUpdate 
@DoctorID = 9,
@DoctorTelPhone = '01612117400',
@DoctorAvailability = 'YES';

SELECT * FROM Doctors



--d) Delete the appointment who status is already completed.
--create a new table 
CREATE TABLE PastAppointmentsHistory (
PastAppointmentID INT PRIMARY KEY,
Date DATE NOT NULL,
Status NVARCHAR(20) NOT NULL,
FeedBack NVARCHAR(50),
DoctorID TINYINT NOT NULL,
CONSTRAINT fk_PastAppointmentsHistory_Doctors FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID));

--insert PastAppointments details into PastAppointmentsHistory
BEGIN TRANSACTION 
BEGIN TRY 
--declare variables
DECLARE @PastAppointmentID INT = 11
DECLARE @Date DATE = '2024-02-17'
DECLARE @Status NVARCHAR(20) = 'completed'
DECLARE @FeedBack NVARCHAR(50) = 'EXCELLENT'
DECLARE @DoctorID TINYINT = 6
--insert values into PastAppointnmentsHistory
INSERT INTO PastAppointmentsHistory(PastAppointmentID, Date, Status, FeedBack, DoctorID) 
VALUES (@PastAppointmentID, @Date, @Status, @FeedBack, @DoctorID); 
COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
-- Catch error if unsuccessful 
IF @@TRANCOUNT > 0 
ROLLBACK TRANSACTION; 
DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
SELECT 
@ErrMsg = ERROR_MESSAGE(), 
@ErrSeverity = ERROR_SEVERITY();
RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH; 

CREATE PROCEDURE usp_deleteCompletedAppointment @Status NVARCHAR(20)
AS
BEGIN
BEGIN TRANSACTION;
BEGIN TRY 
-- delete records from PastAppointmentsHistory table
DELETE FROM PastAppointmentsHistory 
WHERE Status = @Status;
        
COMMIT TRANSACTION;
END TRY

BEGIN CATCH
 -- Catch error if unsuccessful 
IF @@TRANCOUNT > 0 
ROLLBACK TRANSACTION; 
DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT; 
SELECT 
@ErrMsg = ERROR_MESSAGE(), 
@ErrSeverity = ERROR_SEVERITY();
RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
END;

EXEC usp_deleteCompletedAppointment @Status = 'completed'
SELECT * FROM PastAppointmentsHistory



--5. The hospitals wants to view the appointment date and time, showing all previous and current appointments for all doctors, 
--and including details of the department (the doctor is associated with), doctor’s specialty and any associate review/feedback 
--given for a doctor. You should create a view containing all the required information.

CREATE VIEW DoctorsandAppointments(
AppointmentID, AppointmentDate, AppointmentTime, Status, PatientID, DoctorID,
DoctorFirstName, DoctorLastName, DoctorTelPhone, Specialist, DoctorAvailability, 
DepartmentID, DepartmentName,
PastAppointmentID, PastAppointmentDate, PastAppointmentStatus, FeedBack) 
AS 
SELECT
ca.AppointmentID, ca.AppointmentDate, ca.AppointmentTime, ca.Status AS CurrentAppointmentStatus, 
ca.PatientID AS CurrentPatientID, ca.DoctorID AS CurrentDoctorID,
d.DoctorFirstName, d.DoctorLastName, d.DoctorTelPhone, d.Specialist, d.DoctorAvailability,
d.DepartmentID, de.DepartmentName,
pa.PastAppointmentID, pa.Date AS PastAppointmentDate,pa.Status AS PastAppointmentStatus, pa.FeedBack 
FROM Current_Appointments AS ca INNER JOIN Doctors AS d 
ON ca.DoctorID=d.DoctorID INNER JOIN Departments AS de 
ON d.DepartmentID=de.DepartmentID LEFT JOIN PastAppointments as pa 
ON d.DoctorID=pa.DoctorID 

SELECT * FROM DoctorsandAppointments



--6. Create a trigger so that the current state of an appointment can be changed to 
--available when it is cancelled. 
CREATE TRIGGER tr_ChangeAppointmentStatus
ON Current_Appointments
AFTER UPDATE
AS
BEGIN
    -- Check if the 'Status' column was updated to 'cancelled'
    IF  (SELECT COUNT(*) FROM INSERTED WHERE Status = 'cancelled') > 0
    BEGIN
        -- Update the 'Status' to 'available' for all appointments that were cancelled
        UPDATE Current_Appointments
        SET Status = 'available'
        FROM Current_Appointments ca
        INNER JOIN inserted i ON ca.AppointmentID = i.AppointmentID
        WHERE i.Status = 'cancelled';
    END;
END;

 
 UPDATE Current_Appointments
SET Status = 'cancelled'
WHERE AppointmentID = 7;

 --display the content of Current_Appointments
SELECT * FROM Current_Appointments
 


--7. Write a select query which allows the hospital to identify the number of completed 
--appointments with the specialty of doctors as ‘Gastroenterologists’.
SELECT d.DoctorFirstName, d.DoctorLastName, pa.Date, pa.Status
FROM PastAppointments AS pa INNER JOIN Doctors AS d 
	ON pa.DoctorID=d.DoctorID 
WHERE d.Specialist LIKE 'Gastroenterologists'



--Satisfactory Marks 
 
CREATE TABLE ArchivedPatients (
PatientID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
PatientFirstName NVARCHAR(50) NOT NULL, 
PatientMiddleName NVARCHAR(50) NULL, 
PatientLastName NVARCHAR(50) NOT NULL, 
PatientTelephoneNumber NVARCHAR(20) NULL, 
PatientDOB DATE NOT NULL, 
Address NVARCHAR (50) NOT NULL,
Insurance NVARCHAR(15) NULL,
PatientEmailAddress NVARCHAR(100) UNIQUE NOT NULL CHECK (PatientEmailAddress LIKE '%_@_%._%'), 
DateLeft DATE NOT NULL);


CREATE TRIGGER tr_Delete_Patients_Archive 
ON Patients
AFTER DELETE 
AS  
BEGIN
	INSERT INTO ArchivedPatients(PatientFirstName, PatientMiddleName, PatientLastName, PatientTelephoneNumber,
	PatientDOB, Address, Insurance, PatientEmailAddress, DateLeft)  

	SELECT d.PatientFirstName, d.PatientMiddleName, d.PatientLastName, d.PatientTelephoneNumber,
	d.PatientDOB, d.Address, d.Insurance, d.PatientEmailAddress, GETDATE()
	
	FROM DELETED AS d

END

--check if the deleted patient data is stored in the archived table 
SELECT* FROM ArchivedPatients

SELECT * FROM Patients

DELETE FROM Patients 
WHERE PatientID = 8

SELECT * FROM Patients
SELECT * FROM Current_Appointments


--retrieve doctors who have multiple appointments
SELECT (ISNULL(d.DoctorFirstName,'') +  ' ' + ISNULL(d.DoctorLastName,'')) AS DoctorFullName, d.DoctorID 
FROM Doctors AS d INNER JOIN (SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY DoctorID ORDER BY DoctorID) AS rn 
	FROM Current_Appointments) AS c 
ON d.DoctorID=c.DoctorID
WHERE c.rn>1


--using case clause 
SELECT 
PatientFirstName, 
PatientLastName, 
PatientDOB,
CASE   
   WHEN DATEDIFF(YEAR, PatientDOB, GETDATE()) > 40 THEN 'Adult'
   ELSE 'Not Adult'
END AS AgeGroup
FROM PatientsAppointments.Patients;



--Implement Security to the database

--Create Schema 
CREATE SCHEMA PatientsAppointments
GO

ALTER SCHEMA PatientsAppointments TRANSFER dbo.Patients
ALTER SCHEMA PatientsAppointments TRANSFER dbo.DoctorsandAppointments

SELECT * FROM PatientsAppointments.Patients

SELECT * FROM PatientsAppointments.DoctorsandAppointments

--Create login and user
CREATE LOGIN OREZIMEISAAC
WITH PASSWORD = '098765'

CREATE USER OREZIMEISAAC FOR LOGIN OREZIMEISAAC; 
GO

GRANT SELECT ON SCHEMA :: PatientsAppointments TO OREZIMEISAAC

EXECUTE AS USER = 'OREZIMEISAAC'

SELECT * FROM PatientsAppointments.Patients

SELECT * FROM PatientsAppointments.DoctorsandAppointments

SELECT * FROM Departments


--Create Role 
CREATE ROLE CustomerServiceTeam 
GRANT INSERT, UPDATE ON SCHEMA :: PatientsAppointments TO CustomerServiceTeam 

--Adding OREZIMEISAAC User to the role 
ALTER ROLE CustomerServiceTeam ADD MEMBER OREZIMEISAAC





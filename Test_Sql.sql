SELECT
	app.TicketNumber AS encounterKey,
	app.FacilityId AS locationKey,
	pp.PatientId AS personKey,
	guar.GuarantorId AS responsiblePersonKey,
	vis.FinancialClassMId AS financialClassKey,
	NULL AS encounterPatientTypeKey,
	CONVERT(CHAR(10), vis.Visit, 101) AS encounterDate, 
	CONVERT(CHAR(5), vis.Visit, 108) AS encounterTime,
	NULL AS dischargeDate,
	NULL AS dischargeTime,
	aset.Name AS copayAmount,
	app.AppointmentsId AS appointmentKey,
	app.DoctorId AS providerKey,
	CONVERT(CHAR(10), app.ApptStart, 101) AS appointmentDate, 
	CONVERT(CHAR(5), app.ApptStart, 108) AS appointmentTime,
	
	CASE
		WHEN app.Status like '%No show%'
			THEN 1
		ELSE 0
	END AS isNoShow,	
	CASE
		WHEN app.Canceled = 1
			THEN 1
		ELSE 0
	END AS isCanceled,
	apptype.Name AS appointmentType,
	visagg.InsAllocation AS insuranceAllocation,
	visagg.PatAllocation AS patientAllocation,
	visagg.InsPayment AS insurancePayment,
	visagg.PatPayment AS patientPayment,
	visagg.InsAdjustment AS insuranceAdjustment,
	visagg.PatAdjustment AS patientAdjustment,
	visagg.InsBalance AS insuranceBalance,
	visagg.PatBalance AS patientBalance, 
	
	NULL AS PersonRegionalKey,
		NULL AS PersonGlobalKey,
		
		CASE
			WHEN pp.ispatient = 'Y'
				THEN 1
			ELSE 0
		END AS personTypeKey,
		
		pp.First AS personFirstName,
		pp.Last AS personLastName,
		ISDATE(pp.DeathDate) AS isDeceased,
		pp.Birthdate AS personDb,
		
		CASE
			WHEN DATEDIFF(DAY, pp.BirthDate, GETDATE()) >= 6574
				THEN 0
			ELSE 1
		END AS isMinor,
		
		0 AS isMerged, --?
		NULL AS mergedPersonKeys, --?
		NULL AS mergedToKey, --?
		NULL AS personAgentKey,
		pp.EMailAddress AS personEmail,
		pp.LanguageId AS primaryLanguageKey,
		pp.Phone1Type AS preferredCommunicationMethodKey,
		
		CASE
			WHEN (pp.Phone1Type like '%Home%')
				THEN pp.Phone1
			WHEN (pp.Phone2Type like '%Home%')
				THEN pp.Phone2
			WHEN (pp.Phone3Type like '%Home%')
				THEN pp.Phone3		
		END	AS personHomePhone,
		
		CASE
			WHEN (pp.Phone1Type like '%Cell%')
				THEN pp.Phone1
			WHEN (pp.Phone2Type like '%Cell%')
				THEN pp.Phone2
			WHEN (pp.Phone3Type like '%Cell%')
				THEN pp.Phone3		
		END	AS personMobilePhone,
		
		pp.Address1 AS personAddress1,
		pp.Address2 AS personAddress2,
		pp.City AS personCity,
		pp.State AS personState,
		pp.Zip AS personZip
	
FROM centricity..Appointments app
	INNER JOIN centricity..PatientVisit AS vis ON app.PatientVisitId = vis.PatientVisitId
	LEFT JOIN centricity..AllocationSet AS aset ON vis.AllocationSetId = aset.AllocationSetId
	LEFT JOIN centricity..ApptType AS apptype ON app.ApptTypeId = apptype.ApptTypeId
	INNER JOIN centricity..PatientProfile AS pp ON vis.PatientProfileId = pp.PatientProfileId
	INNER JOIN centricity..InsuranceCarriers AS insc ON vis.PrimaryInsuranceCarriersId = insc.InsuranceCarriersId
	INNER JOIN centricity..Guarantor AS guar ON pp.GuarantorId = guar.GuarantorId
	INNER JOIN centricity..PatientVisitAgg AS visagg ON app.PatientVisitId = visagg.PatientVisitId
	
--WHERE (ApptStart BETWEEN GETDATE()AND DATEADD(DAY,14,GETDATE()))
--WHERE (app.LastModified BETWEEN DATEADD(DAY,-1,GETDATE()) AND DATEADD(DAY,1,GETDATE()))
--WHERE (app.LastModified BETWEEN DATEADD(HOUR,-1,GETDATE()) AND DATEADD(HOUR,1,GETDATE()))
--WHERE (app.LastModified BETWEEN DATEADD(MINUTE,-1,GETDATE()) AND DATEADD(MINUTE,1,GETDATE())) 
--OR (visagg.LastModified BETWEEN DATEADD(MINUTE,-1,GETDATE()) AND DATEADD(MINUTE,1,GETDATE()))
WHERE visagg.PatBalance > '0.00' 
-- Data Cleaning

-- Data Exploring

SELECT *
FROM dbo.[Nashville Housing]


----------------------------------------------------------------------------------------------------------------------------

-- Standardized Date Format (Sale Date)

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM dbo.[Nashville Housing]


-----------------------------------------------------------------------------------------------------------------------------

-- Replacing Sale Date to New Date Format

ALTER TABLE [Nashville Housing]
ADD Sale_Date Date;

UPDATE [Nashville Housing]
SET Sale_Date = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------------------------------------------------------

-- Checking New Date Format

SELECT *
FROM [Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------------

-- Delete original SaleDate

ALTER TABLE [Nashville Housing]
DROP COLUMN SaleDate


----------------------------------------------------------------------------------------------------------------------------------

-- Identify missing Property Address

SELECT PropertyAddress
FROM [Nashville Housing]
WHERE PropertyAddress IS NULL

-- Organize by Parcel ID to find if same Parcel ID has same Property Address

SELECT *
FROM [Nashville Housing]
ORDER BY ParcelID

------------------------------------------------------------------------------------------------------------------------------------

-- Populate missing Property Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------------------------------------------

-- Break out Property Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM [Nashville Housing]


---------------------------------------------------------------------------------------------------------------------------------------------

-- Update Table with splitted Address & City

ALTER TABLE [Nashville Housing]
ADD Property_Address NVARCHAR(255);

UPDATE [Nashville Housing]
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE [Nashville Housing]
ADD Property_City NVARCHAR(255);

UPDATE [Nashville Housing]
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Property Address Column

ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------------

-- Breake out Owner Address into individual columns (Address, City, State)

SELECT OwnerAddress
FROM [Nashville Housing]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Nashville Housing]


------------------------------------------------------------------------------------------------------------------------------------------------------

-- Update Table with splitted Owner Address

ALTER TABLE [Nashville Housing]
ADD Owner_Address NVARCHAR(255);

UPDATE [Nashville Housing]
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing]
ADD Owner_City NVARCHAR(255);

UPDATE [Nashville Housing]
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing]
ADD Owner_State NVARCHAR(255);

UPDATE [Nashville Housing]
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete OwnerAddress column

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress


------------------------------------------------------------------------------------------------------------------------------------------------------

-- Display number of each Yes, No, Y, and N

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2


-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change 'Y' to 'Yes' and 'N' to 'No'

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Nashville Housing]


---------------------------------------------------------------------------------------------------------------------------------------------------------

--UPDATE TABLE with 'Yes' and 'No'

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 Address,
				 City,
				 SalePrice,
				 Sale_Date,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Nashville Housing]
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------------------------------------------------------------------------------------------------------------------

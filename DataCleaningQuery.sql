
-- Cleaning Data in SQL Queries


SELECT *
FROM DataCleaningProject..NashvilleHousing

-----------------------------------------------

--Standardize Date Format


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM DataCleaningProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject..NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject..NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---------------------------------------------------------------------

-- Breaking out Address into individual columns (address, city, state)

SELECT PropertyAddress
FROM DataCleaningProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 
 , LEN(PropertyAddress)) AS Address
FROM DataCleaningProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 
 , LEN(PropertyAddress))

 SELECT *
 FROM DataCleaningProject..NashvilleHousing







 SELECT OwnerAddress
 FROM DataCleaningProject..NashvilleHousing


 Select
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
  FROM DataCleaningProject..NashvilleHousing


  -- Add Residence Address


  ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


-- Add City


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


 -- Add State

 
 ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



----------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold As Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM DataCleaningProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				) row_num


FROM DataCleaningProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------------------------------------------------------------



SELECT *
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN SaleDate






	

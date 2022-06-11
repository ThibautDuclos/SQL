-- Standardize Date Format

SELECT * 
FROM PProject.dbo.NashvilleHousing

SELECT SaleDateConverted,
CONVERT (Date,SaleDate)
FROM PProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate property address data

SELECT *
FROM PProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PProject.dbo.NashvilleHousing A
JOIN PProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PProject.dbo.NashvilleHousing A
JOIN PProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress is NULL


--Break down of the Address into Columns (Address, City, State)

SELECT PropertyAddress
FROM PProject.dbo.NashvilleHousing

--SELECT
--PARSENAME(REPLACE(PropertyAddress, ',', ','), 2) AS Street
--,PARSENAME(REPLACE(PropertyAddress, ',', ','), 1) AS City
--FROM PProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PProject.dbo.NashvilleHousing

ALTER TABLE PProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PProject.dbo.NashvilleHousing
SET PropertySplitAddress
= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PProject.dbo.NashvilleHousing
SET PropertySplitCity 
= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PProject.dbo.NashvilleHousing

--Owner

SELECT OwnerAddress
FROM PProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Street
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
From PProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PProject.dbo.NashvilleHousing

ALTER TABLE PProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

UPDATE PProject.dbo.NashvilleHousing
SET OwnerSplitAddress 
= PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE PProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE PProject.dbo.NashvilleHousing
SET OwnerSplitCity
= PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE PProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255)

UPDATE PProject.dbo.NashvilleHousing
SET OwnerSplitState 
= PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM PProject.dbo.NashvilleHousing

--Change Y and N for Yes and No in "Sold as vacant"

SELECT Distinct(SoldasVacant), Count(SoldasVacant)
FROM PProject.dbo.NashvilleHousing
Group by SoldasVacant
Order by 2

SELECT SoldasVacant,
CASE when SoldasVacant = 'Y' then 'YES'
	 When SoldasVacant = 'N' then 'NO'
	 ELSE SoldasVacant
	 END
FROM PProject.dbo.NashvilleHousing

UPDATE PProject.dbo.NashvilleHousing
SET SoldasVacant = CASE when SoldasVacant = 'Y' then 'YES'
	 When SoldasVacant = 'N' then 'NO'
	 ELSE SoldasVacant
	 END

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
FROM PProject.dbo.NashvilleHousing)

SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress

--Delete unused columns(not recommended on row Data)

SELECT *
FROM PProject.dbo.NashvilleHousing

ALTER TABLE PProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

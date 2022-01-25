

--  Cleaning Data in SQL Queries

Select * 
From [Portfolio Project]..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConvert DATE

Update NashvilleHousing
SET SaleDateConvert = CONVERT(date, SaleDate)

Select SaleDateConvert, CONVERT(Date,SaleDate)
From [Portfolio Project]..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

Select *
FROM [Portfolio Project]..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID
;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Coulmns (Address, City, State)

Select PropertyAddress
FROM [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM [Portfolio Project]..NashvilleHousing 

USE [Portfolio Project]
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--ALTER TABLE NashvilleHousing

Select *
FROM [Portfolio Project]..NashvilleHousing; 

-- Break out 'State' from OwnerAddress

Select OwnerAddress
From [Portfolio Project]..NashvilleHousing;

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Portfolio Project]..NashvilleHousing;

USE [Portfolio Project]
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

USE [Portfolio Project]
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

USE [Portfolio Project]
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
FROM [Portfolio Project]..NashvilleHousing; 


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to 'Yes' and 'No' in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant 
 , CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM [Portfolio Project]..NashvilleHousing;
	
Update NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


--------------------------------------------------------------------------------------------------------------------------


-- Remove Dupliactes

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER 
	(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) Row_Num


FROM [Portfolio Project]..NashvilleHousing
)
Select *
FROM RowNumCTE
WHERE Row_Num > 1
;


---------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From [Portfolio Project]..NashvilleHousing

USE [Portfolio Project]
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

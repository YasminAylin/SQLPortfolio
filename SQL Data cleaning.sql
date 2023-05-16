/*

--Data Cleaning 

*/


SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------
--Standardize Data Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing


ALTER table NashvilleHousing
add SaleDateConverted Date


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


SELECT SaleDateConverted
FROM NashvilleHousing

---------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


---------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Adrress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing


ALTER table NashvilleHousing
add PropertySplitAddress Nvarchar(255)


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255)


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER table NashvilleHousing
add OwnerSplitCity Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



---------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END



---------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
				   PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
					  UniqueID
					) AS row_num
FROM NashvilleHousing
)
SELECT *
FROM  RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


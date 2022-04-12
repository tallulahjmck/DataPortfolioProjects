/*
Cleaning Data in SQL Queries - Making the Data more Useable and standardised 
*/


Select *
From PortfolioProject.dbo.Housing$

--------------------------------------------------------------------------------------------------------------------------
-- Standardising the Date Format
-- Changing the format to make it a bit more readable 

ALTER TABLE PortfolioProject..Housing$
ALTER COLUMN SaleDate DATE


 --------------------------------------------------------------------------------------------------------------------------

---- Populate Property Address data

Select *
From PortfolioProject.dbo.Housing$
Where PropertyAddress is null
order by ParcelID

-- joined table where parcel id is the same, but its not the same row (we need to keep unique ID)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Housing$ a
JOIN PortfolioProject.dbo.Housing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- No NULL property addresses!


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Housing$ a
JOIN PortfolioProject.dbo.Housing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.Housing$
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.Housing$


ALTER TABLE PortfolioProject..Housing$
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..Housing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject..Housing$
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..Housing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-----------------------------------------------------


Select *
From PortfolioProject.dbo.Housing$


-- Breaking out Address into Individual Columns (Address, City, State)


Select OwnerAddress
From PortfolioProject.dbo.Housing$


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.Housing$



ALTER TABLE PortfolioProject..Housing$
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..Housing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..Housing$
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..Housing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..Housing$
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..Housing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.Housing$




----------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.Housing$
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.Housing$


Update PortfolioProject.dbo.Housing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



Select *
From PortfolioProject.dbo.Housing$


-------------------------------------------------------------------------------------------------------------------------------------------------------------

------ Remove Duplicates

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.Housing$
order by ParcelID

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.Housing$
--order by ParcelID
)
--DELETE
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.Housing$




-----------------------------------------------------------------------------------------------------------

---- Delete Unused Columns



Select *
From PortfolioProject.dbo.Housing$


ALTER TABLE PortfolioProject.dbo.Housing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
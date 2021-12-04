-- Cleaning Data - Project -----------------------------------------------

select * 
from dbo.NashvileHousing

-- Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
from dbo.NashvileHousing

Update dbo.NashvileHousing
SET SaleDate = Convert(Date,SaleDate)

Select SaleDate
from dbo.NashvileHousing

-- It hasn't converted . let us try someother method

Alter table NashvileHousing
Add SaleDateConverted Date;

Update dbo.NashvileHousing
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
from dbo.NashvileHousing

--we have converted the date column. Will remove the Extra columns afr==terwards

-- Populate Property Address Data

Select  PropertyAddress 
from PortfolioProject.dbo.NashvileHousing
Where PropertyAddress is null   -- we have so many null values

Select *
from NashvileHousing
where PropertyAddress is null
order by ParcelID

Select *
from NashvileHousing
order by ParcelID    -- we can find duplicates from this in parcel id

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from PortfolioProject.dbo.NashvileHousing a
join PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
 where a.PropertyAddress is null

 select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing a
join PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
 where a.PropertyAddress is null

 Update a
 set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject.dbo.NashvileHousing a
join PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from PortfolioProject.dbo.NashvileHousing a
join PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null      -- we have removed all null values from the Property Address by assigning values from similar data

select * from NashvileHousing

-----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address,City,State)

select PropertyAddress
from PortfolioProject.dbo.NashvileHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as CITY
from PortfolioProject.dbo.NashvileHousing    -- we add -1 to remove , such that it takes the -1 position from the position of ,

Alter table NashvileHousing
Add PropertySplitAddress nvarchar(255);

Update dbo.NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter table NashvileHousing
Add PropertySplitCity nvarchar(255);

Update dbo.NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from NashvileHousing


--simpler way to do it

Select OwnerAddress
from NashvileHousing

select
OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from NashvileHousing

Alter table NashvileHousing
Add OwnerSplitAddress nvarchar(255);

Update dbo.NashvileHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table NashvileHousing
Add OwnerSplitCity nvarchar(255);

Update dbo.NashvileHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table NashvileHousing
Add OwnerSplitState nvarchar(255);

Update dbo.NashvileHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select * from NashvileHousing

----------------------------------------------------------------------------------------------------------------
---- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvileHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 Else SoldASVacant
	 END
from NashvileHousing

update NashvileHousing 
Set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 Else SoldASVacant
	 END

Select * from NashvileHousing

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvileHousing
Group by SoldAsVacant
order by 2


--------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS(
Select *,
	row_number() over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
					)row_num

from NashvileHousing
)
SELECT * FROM RowNumCTE 
where row_num>1 
order by PropertyAddress

-- This are duplicates . Let us remove it using delete command

With RowNumCTE AS(
Select *,
	row_number() over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
					)row_num

from NashvileHousing
)
Delete
FROM RowNumCTE 
where row_num>1 

-- All duplicates are removed

-----------------------------------------------------------------------------------------------------------------------

--Delete Unused column

Select *
from NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
from NashvileHousing

----------------------------------------------------------------------------------------------------------------------------------------------------
--------Data Cleaning Done ----------------------------------------------------------------------------------------------------
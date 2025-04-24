/* 

CLeaning Data in SQL Queries

*/


----------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, Convert(Date,SaleDate) from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)



----------------------------------------------------------------------------------------------------------------------------------------

--Populted Property Address Area

Select PropertyAddress from PortfolioProject..NashvilleHousing
Where PropertyAddress is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a  
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

----------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns

Select SUBSTRING ( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING ( PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
--Drop Column PropertySplitAddress (If you want to change the Character or made some error and want to delete the column)
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING ( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING ( PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


Select PARSENAME(Replace(OwnerAddress,',', '.'), 3),
PARSENAME(Replace(OwnerAddress,',', '.'), 2),
PARSENAME(Replace(OwnerAddress,',', '.'), 1)FROM PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)



----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant) from PortfolioProject..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing 
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END



----------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates


With RowNumCTE as(
Select *, ROW_NUMBER() Over(
			Partition By ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 Order By
							UniqueID) row_num
From NashvilleHousing
)
Select * from RowNumCTE
where row_num >1


----------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate


Select * From PortfolioProject..NashvilleHousing
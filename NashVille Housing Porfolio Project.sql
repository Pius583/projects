/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing


-- Standardize Date Format

Select SalesDateConverted, Convert(Date, SaleDate) As NewSalesDate
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

-- Alternative Method For Updating Date Format

Alter Table  NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing
Set SalesDateConverted = Convert(Date, SaleDate)


-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, Isnull(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject..NashvilleHousing As A
Join PortfolioProject..NashvilleHousing As B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

Update A
Set PropertyAddress = Isnull(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject..NashvilleHousing As A
Join PortfolioProject..NashvilleHousing As B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) As Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) As Address

From PortfolioProject..NashvilleHousing

Alter Table  NashvilleHousing
Add ProperySplitAddress Nvarchar(260);

Update NashvilleHousing
Set ProperySplitAddress  = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table  NashvilleHousing
Add PropertySplitDetails Nvarchar(260);

Update NashvilleHousing
Set PropertySplitDetails = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing



Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3)
,Parsename(Replace(OwnerAddress, ',', '.'), 2)
,Parsename(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table  NashvilleHousing
Add OwnerSplitAddress Nvarchar(260);

Update NashvilleHousing
Set OwnerSplitAddress  = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table  NashvilleHousing
Add OwnerSplitCity Nvarchar(260);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table  NashvilleHousing
Add PropertySplitState Nvarchar(260);

Update NashvilleHousing
Set PropertySplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,  Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End


-- Remove Duplicates


With RowNumCTE As(
Select *,
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) Row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousing


--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


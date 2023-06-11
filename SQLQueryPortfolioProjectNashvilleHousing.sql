Select * 
From NashvilleHousing

Select SaleDateConverted, Convert(Date, SaleDate)  
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


--Filling in Null Values for Proprety Address Data

Select * 
From NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)    
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


-- Changing Address Data into Seperate Columns (Address, City, Sate) 

Select PropertyAddress 
From NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing


Alter Table NashvilleHousing
Add PropertySeperatedAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySeperatedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySeperatedCity Nvarchar(255);

Update NashvilleHousing
Set PropertySeperatedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





Select OwnerAddress 
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSeperatedAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSeperatedAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSeperatedCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSeperatedCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSeperatedState Nvarchar(255);

Update NashvilleHousing
Set OwnerSeperatedState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


-- Changing the Y and N Columns to Yes and No within "Sold as Vacant" Field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No' 
	 Else SoldAsVacant
	 End
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No' 
	 Else SoldAsVacant
	 End


-- Removing Duplicates

With RowNumCTE as(
Select *,
	Row_Number() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1



--Deleting Unused Columns

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict 

Alter table NashvilleHousing
Drop column SaleDate
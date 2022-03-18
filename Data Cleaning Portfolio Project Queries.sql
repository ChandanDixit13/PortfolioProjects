/* 

Cleaning data in SQL queries

*/

Select * 
From Project.dbo.NashvilleHousing

--Standarize Date Format

Select SaleDateConverted, CONVERT(date,SaleDate)
From Project.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

-- Populate Property Address Data 


Select * 
From Project.dbo.NashvilleHousing
--where PropertyAddress is null
Order By ParcelID


Select a.ParcelID ,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.NashvilleHousing a
Join Project.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null
	
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.NashvilleHousing a
Join Project.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


-- Breaking out Address into Individual Columns(Address,City ,State)

Select PropertyAddress
From Project.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From Project.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

Select * 
From Project.dbo.NashvilleHousing



select OwnerAddress
From Project.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',', '.'), 3),
PARSENAME(Replace(OwnerAddress,',', '.'), 2),
PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From Project.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)


--Change Y and N to Yes and No in 'Sold As Vacant" field 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Project.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From Project.dbo.NashvilleHousing

Update Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates 


With RowNumCTE AS(
Select * ,
     ROW_NUMBER() Over(
	 Partition By ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order by 
				  UniqueID) row_num
From Project.dbo.NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num >1
Order By PropertyAddress


--Remove unused columns 

Select * 
From Project.dbo.NashvilleHousing

Alter Table Project.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
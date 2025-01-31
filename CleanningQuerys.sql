select * 
from CleanningDataSet..NashvilleHousing

order by ParcelID

-- Standardize Date Format
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------
--fixing null values in Propertyaddress
select * 
from CleanningDataSet..NashvilleHousing

order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From CleanningDataSet..NashvilleHousing a
join CleanningDataSet..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From CleanningDataSet..NashvilleHousing a
join CleanningDataSet..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------------
--breaking out address into individual columns (address, city, state)


select * 
from CleanningDataSet..NashvilleHousing
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as address
from CleanningDataSet..NashvilleHousing


ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);


ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


select * 
from CleanningDataSet..NashvilleHousing
--order by ParcelID

Select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from CleanningDataSet..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);


ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)



----------------------------------------------------------------

--changing Y and N to Yes and No in sold as vacant column

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from CleanningDataSet..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from CleanningDataSet..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END


-----------------------------------------

--REMOVE DUPLICATES

WITH RowNumCTE as(
select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY
										UniqueID
										) row_num
from CleanningDataSet..NashvilleHousing
)

SELECT *
From RowNumCTE
where row_num > 1
order by PropertyAddress


---------------------------------------

--DELETE unused columns


Select *
from CleanningDataSet..NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress,TaxDistrict, PropertyAddress, SaleDate
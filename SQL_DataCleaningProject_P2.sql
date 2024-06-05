/* Data Cleaning in SQL */

/* 1. Standardize date format */
select * from Nashville_Housing_Society

/* update Nashville_Housing_Society
set SaleDate = CONVERT(date, SaleDate) */

Alter table Nashville_Housing_Society
Add Sale_Date_Converted date 

update Nashville_Housing_Society
set Sale_Date_Converted = CONVERT(date, SaleDate)

select Sale_Date_Converted from Nashville_Housing_Society


/* 2. Populate Property address data */

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Nashville_Housing_Society a
Join Nashville_Housing_Society b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing_Society a
Join Nashville_Housing_Society b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


/* 3. Breaking out address into individual columns (Address, City, State) */

select PropertyAddress from Nashville_Housing_Society

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address1 
from Nashville_Housing_Society --this will only display the information before the comma 

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address1 ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2
from Nashville_Housing_Society --this will display information that will exclude ','

alter table Nashville_Housing_Society  --for address1
add Property_Split_Address nvarchar(255);

update Nashville_Housing_Society --updating address1
set Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table Nashville_Housing_Society  --for address2
add Property_Split_City nvarchar(255);

update Nashville_Housing_Society --updating address2
set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select * from Nashville_Housing_Society


-- EASY WAY TO THE ABOVE TASK

select PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from Nashville_Housing_Society

Alter table Nashville_Housing_Society --for seperate address (1)
Add Owner_Address nvarchar(255);

update Nashville_Housing_Society --updating the address and distinguishing further
set Owner_Address = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table Nashville_Housing_Society --for seperate address (2)
Add Owner_Address_City nvarchar(255);

update Nashville_Housing_Society --updating the address and distinguishing further
set Owner_Address_City = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table Nashville_Housing_Society --for seperate address (3)
Add Owner_Address_State nvarchar(255);

update Nashville_Housing_Society --updating the address and distinguishing further
set Owner_Address_State = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select * from Nashville_Housing_Society


/* 4. Change Y & N to Yes & No in "SoldAsVacant" field */

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Nashville_Housing_Society
group by SoldAsVacant
order by 2

update Nashville_Housing_Society
set SoldAsVacant = case when SoldAsVacant= 'Y' then 'Yes'
                   when SoldAsVacant= 'N' then 'No'
				   else SoldAsVacant
				   end

select SoldAsVacant from Nashville_Housing_Society

/* 5. Remove Duplicates */

With RowNumCTE as
(
select *, ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num
from Nashville_Housing_Society
)


delete from RowNumCTE
where row_num > 1


select * from RowNumCTE
where row_num > 1
order by PropertyAddress

/* 6. Delete unused Columns */

Alter table Nashville_Housing_Society
drop column PropertyAddress, SaleDate, TaxDistrict, Owner_Address

select * from Nashville_Housing_Society
Select *
From Portfolio_Project_Nashville_Housing..NashvilleHousing

-- Standardization of date format

Select SaleDate, Convert(Date, SaleDate) as SaleDate_New
From Portfolio_Project_Nashville_Housing..NashvilleHousing

Alter Table  Portfolio_Project_Nashville_Housing..NashvilleHousing
Add SaleDate_New Date

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set SaleDate_New = Convert(Date, SaleDate) 

Select SaleDate, SaleDate_New 
From Portfolio_Project_Nashville_Housing..NashvilleHousing

---------------------------------------------------------------------------------

-- Populate Property Adress Data (Fill in The Nulls of the PropertyAdress Column)

Select ParcelID, PropertyAddress
From Portfolio_Project_Nashville_Housing..NashvilleHousing

	-- We can see that the same ParcelID can have a normal address and a null value at the same time in two different rows. 
	-- My goal is to fill in the nulls with the missing address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Portfolio_Project_Nashville_Housing..NashvilleHousing a
Join Portfolio_Project_Nashville_Housing..NashvilleHousing b
	On a.ParcelID = b.ParcelID and
	   a.UniqueID<>b.UniqueID
Where a.PropertyAddress is Null

	-- Now we have the null PropertyAddress and the correct one next to each other

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project_Nashville_Housing..NashvilleHousing a
Join Portfolio_Project_Nashville_Housing..NashvilleHousing b
	On a.ParcelID = b.ParcelID and
	   a.UniqueID<>b.UniqueID
Where a.PropertyAddress is Null

	-- Now to change the nulls into the actuall addresses

Update a
Set PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project_Nashville_Housing..NashvilleHousing a
Join Portfolio_Project_Nashville_Housing..NashvilleHousing b
	On a.ParcelID = b.ParcelID and
	   a.UniqueID<>b.UniqueID
Where a.PropertyAddress is Null

-----------------------------------------------------------------------------------------------	

--Breaking down PropertryAddress into individual columns

Select SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as PropertyAddress_New
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as PropertyCity
From Portfolio_Project_Nashville_Housing..NashvilleHousing

	--Now to add the two new columns

Alter Table Portfolio_Project_Nashville_Housing..NashvilleHousing
Add PropertyAddress_New nvarchar(255)

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set PropertyAddress_New = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

Alter Table Portfolio_Project_Nashville_Housing..NashvilleHousing
Add PropertyCity nvarchar(255)

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress))

-- Now to do the same with the OwnerAddress column. Here we will create three new columns since the State is also present, apart from address and city
	--We will use Parsename instead of Substring

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerAddress
, PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerCity
, PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerState
From Portfolio_Project_Nashville_Housing..NashvilleHousing

	-- Now to create the three respective new columns

Alter Table Portfolio_Project_Nashville_Housing..NashvilleHousing
Add OwnerAddress_New nvarchar(255)

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set OwnerAddress_New = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table Portfolio_Project_Nashville_Housing..NashvilleHousing
Add OwnerCity nvarchar(255)

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table Portfolio_Project_Nashville_Housing..NashvilleHousing
Add OwnerState nvarchar(255)

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------
-- Change Yes and No to Y and N respectively in 'Sold as Vacant' column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio_Project_Nashville_Housing..NashvilleHousing
Group by SoldAsVacant
Order by COUNT(SoldAsVacant)

Select SoldAsVacant,
	   case when SoldAsVacant = 'Yes' then 'Y'
	        When SoldAsVacant = 'No' then 'N'
			else SoldAsVacant
       end
From Portfolio_Project_Nashville_Housing..NashvilleHousing

	-- Now to update the table

Update Portfolio_Project_Nashville_Housing..NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Yes' then 'Y'
			       When SoldAsVacant = 'No' then 'N'
			       else SoldAsVacant
                   end

				   ---------------------------------------------------------------------------------------
--Remove Duplicates

	-- Let's consider that when values in  ParcelID, PropertyAddress_New, PropertyCity, SalePrice, LegalReference columns
	--are the same, then we have duplicate rows

Select ParcelID, PropertyAddress_New, PropertyCity, SalePrice, LegalReference
, ROW_NUMBER() over (
Partition by ParcelID, 
			PropertyAddress_New, 
			PropertyCity, 
			SalePrice, 
			LegalReference Order by UniqueID) as row_num
From Portfolio_Project_Nashville_Housing..NashvilleHousing
Order by ParcelID

	--Since we cannot use order by row_num here we will have to create a CTE

With DuplicatesCTE as (
Select ParcelID, PropertyAddress_New, PropertyCity, SalePrice, LegalReference
, ROW_NUMBER() over (
Partition by ParcelID, 
			PropertyAddress_New, 
			PropertyCity, 
			SalePrice, 
			LegalReference Order by UniqueID) as row_num
From Portfolio_Project_Nashville_Housing..NashvilleHousing
)

Select * 
From DuplicatesCTE
Where row_num <> 1
Order by ParcelID

	-- 121 rows of duplicates were populated. We should delete them

With DuplicatesCTE as (
Select ParcelID, PropertyAddress_New, PropertyCity, SalePrice, LegalReference
, ROW_NUMBER() over (
Partition by ParcelID, 
			PropertyAddress_New, 
			PropertyCity, 
			SalePrice, 
			LegalReference Order by UniqueID) as row_num
From Portfolio_Project_Nashville_Housing..NashvilleHousing
)

Delete 
From DuplicatesCTE
Where row_num <> 1

------------------------------------------------------------------------------------
--Remove unwanted columns

	-- Saledate, PropertyAddress, OwnerAddress columns as well as TaxDistrict column are not needed
	
Alter Table Portfolio_Project_Nashville_Housing..NashvilleHousing
Drop Column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict

Select * 
From Portfolio_Project_Nashville_Housing..NashvilleHousing

-- Rename some columnns we created
-- Using the object explorer we rename the columns PropertyAddess_New to PropertyAddess
-- OwnerAddress_New to OwnerAddress and
-- SaleDate_New to SaleDate

-- Remove some bad data. The ParcelID column has generally the format 'nnn nn n nnn.nn', BUT in some rows we can see the pattern changes and becomes
-- 'nnn nn nC nnn.nn' where C = a capital letter. These rows are problematic because they have too much NULL values and thus
-- are of no use. We will create a temp table and put all these bad values there

Select *
From Portfolio_Project_Nashville_Housing..NashvilleHousing
Where ParcelID like '%[A-Z]%'

Create Table #NashvilleHousing_BadData	(
UniqueID float,
ParcelID nvarchar(255),
LandUse nvarchar(255),
SalePrice float,
LegalReference nvarchar(255),
SoldAsVacant nvarchar (255),
OwnerName nvarchar (255),
Acreage float,
LandValue float,
BuildingValue float,
TotalValue float,
YearBuilt float,
Bedrooms float,
FullBath float,
HalfBath float,
SaleDate_New date,
PropertyAddress_New nvarchar(255),
PropertyCity nvarchar(255),
OwnerAddress_New nvarchar(255),
OwnerCity nvarchar(255),
OwnerState nvarchar(255)
)


Insert into #NashvilleHousing_BadData
Select *
From Portfolio_Project_Nashville_Housing..NashvilleHousing
Where ParcelID like '%[A-Z]%'

	-- Almost 29000 rows of bad data!

Select * 
From #NashvilleHousing_BadData

	-- Now we can delete those bad data from the NashvilleHousing table

Delete From Portfolio_Project_Nashville_Housing..NashvilleHousing
Where ParcelID like '%[A-Z]%'


	-- Despite the huge cleaning of bad data, we can see there are some who persist.
	-- After carefully looking at our remaining data we can see that the remaining bad have also NULL values
	-- starting from the column 'OwnerName' up to 'Halfbath'. Let us see if we can gather them up.

Select *
From Portfolio_Project_Nashville_Housing..NashvilleHousing
Where OwnerName is Null and HalfBath Is NULL

	-- 1497 rows were populated, in many of which all the columns from 'OwnerName' to 'Halfbath' have NUll values,
	-- rendering them useless. There are some rows in which there are less NULL values, but they nevertheless offer
	-- incomplete information and are going to be removed. We are going to add all these rows to #NashvilleHousing_BadData
	-- temp table.

Insert into #NashvilleHousing_BadData
Select *
From Portfolio_Project_Nashville_Housing..NashvilleHousing
Where OwnerName is Null and HalfBath Is NULL

Select * 
From #NashvilleHousing_BadData


	-- So we finally have almost 30000 rows of bad data stored in our temp table. Perhaps in the future 
	-- we get more information about those and can add them back in.
	-- Now to delete these 1497 rows from our NashvilleHousing table

Delete From Portfolio_Project_Nashville_Housing..NashvilleHousing
Where OwnerName is Null and HalfBath Is NULL

	-- Some 25000 rows remaining, there are some NULL values per row left but not so many as before and 
	-- the remaining info is usable.
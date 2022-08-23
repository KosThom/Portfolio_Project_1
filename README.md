# Data Cleaning using SQL
In this project my goal is to do some data cleaning using SQL on a housing dataset (almost 56000 rows).
In the end less than half of the original data remains (almost 25000 rows).
The bad data are stored in a Temp table. So in case some missing data become available in the future
they could be added back in.
In short I:
1. standardize the date format
2. fill in Null values in the PropertyAdress column where that is possible
3. break down the PropertyAddress column into two columns, since it contains two pieces of info (address and city). I use SUBSTRING combined with CHARINDEX for that.
4. do the same with the OwnerAdress column but break it down to three columns (contains address, city and state info). This time I am using PARSENAME combined with REPLACE
5. change the YES and NO from the SoldAsVacant column into Y and N respectively
6. remove duplicates using ROW_NUMBER() and CTE
7. remove unwanted columns
8. remove rows with many Null values that are of no use and I put them in a bad-data-temp-table
9. can see that despite our cleaning of bad data previously, some persist. I gather and transfer the last of it to the temp table I created before. Some Null values are still present in some rows but they are far fewer than before and the respective rows are usable.


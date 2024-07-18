




--
-- Database: `pharmacy`
--

-- --------------------------------------------------------

--
-- Table structure for table `company`
--
create database ournewpharmacy;
use ournewpharmacy;

CREATE TABLE `company` (
  `NAME` varchar(50) primary key NOT NULL,
  `ADDRESS` varchar(50) NOT NULL,
  `PHONE` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`NAME`, `ADDRESS`, `PHONE`) VALUES
('Cipla', 'Mumbai', '12903'),
('Sun Pharma', 'Mysore', '01289078443'),
('Med_City', 'Nellore', '010114367832');

-- --------------------------------------------------------

--
-- Table structure for table `drugs`
--

CREATE TABLE `drugs` (
  `NAME` varchar(50) NOT NULL,
  `TYPE` varchar(20) NOT NULL,
  `BARCODE` varchar(20) primary key NOT NULL,
  `DOSE` varchar(10) NOT NULL,
  `CODE` varchar(10) NOT NULL,
  `COST_PRICE` double NOT NULL,
  `SELLING_PRICE` double NOT NULL,
  `EXPIRY` varchar(20) NOT NULL,
  `COMPANY_NAME` varchar(50) NOT NULL,
  `PRODUCTION_DATE` date NOT NULL,
  `EXPIRATION_DATE` date NOT NULL,
  `PLACE` varchar(20) NOT NULL,
  `QUANTITY` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `drugs`
--


-- --------------------------------------------------------

--
-- Table structure for table `expiry`
--

CREATE TABLE `expiry` (
  `PRODUCT_NAME` varchar(50) NOT NULL,
  `PRODUCT_CODE` varchar(20) primary key NOT NULL,
  `DATE_OF_EXPIRY` varchar(10) NOT NULL,
  `QUANTITY_REMAIN` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `history_sales`
--

CREATE TABLE `history_sales` (
  `USER_NAME` varchar(20) NOT NULL,
  `BARCODE` varchar(20) primary key NOT NULL,
  `NAME` varchar(50) NOT NULL,
  `TYPE` varchar(10) NOT NULL,
  `DOSE` varchar(10) NOT NULL,
  `QUANTITY` int(11) NOT NULL,
  `PRICE` double NOT NULL,
  `AMOUNT` double NOT NULL,
  `DATE` varchar(15) NOT NULL,
  `TIME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `history_sales`
--


-- --------------------------------------------------------

--
-- Table structure for table `inbox`
--



--
-- Dumping data for table `inbox`
--



-- --------------------------------------------------------

--
-- Table structure for table `login`
--



--
-- Dumping data for table `login`
--



-- --------------------------------------------------------

--
-- Table structure for table `message_history`
--

-- --------------------------------------------------------

--
-- Table structure for table `purchase`
--

CREATE TABLE `purchase` (
  `BARCODE` varchar(20) NOT NULL,
  `NAME` varchar(50) NOT NULL,
  `TYPE` varchar(20) NOT NULL,
  `COMPANY_NAME` varchar(20) NOT NULL,
  `QUANTITY` int(11) NOT NULL,
  `PRICE` double NOT NULL,
  `AMOUNT` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `purchase`
--

INSERT INTO `purchase` (`BARCODE`, `NAME`, `TYPE`, `COMPANY_NAME`, `QUANTITY`, `PRICE`, `AMOUNT`) VALUES
('fsdgjfihjorodsf', 'Novalo', 'Bills', 'Med_City', 40, 2, 80);

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

CREATE TABLE `sales` (
  `BARCODE` varchar(20) NOT NULL,
  `NAME` varchar(50) NOT NULL,
  `TYPE` varchar(10) NOT NULL,
  `DOSE` varchar(10) NOT NULL,
  `QUANTITY` int(11) NOT NULL,
  `PRICE` double NOT NULL,
  `AMOUNT` double NOT NULL,
  `DATE` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `ID` int(11) NOT NULL PRIMARY KEY,
  `NAME` varchar(50) NOT NULL,
  `DOB` varchar(20) NOT NULL,
  `ADDRESS` varchar(100) NOT NULL,
  `PHONE` varchar(20) NOT NULL,
  `SALARY` double NOT NULL,
  `PASSWORD` varchar(20) NOT NULL,
  `role` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

--
-- Indexes for dumped tables
--

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`NAME`);

--
-- Indexes for table `drugs`
--
ALTER TABLE `drugs`
  ADD PRIMARY KEY (`BARCODE`);

--
-- Indexes for table `purchase`
--
ALTER TABLE `purchase`
  ADD PRIMARY KEY (`BARCODE`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`ID`);
--
-- Indexes for table `purchase`
--  
  ALTER TABLE purchase 
  add constraint fkr3
  foreign key(company_name)
  references company(name) 
  on update cascade on delete cascade;
  
  ALTER TABLE 

DELIMITER //

CREATE TRIGGER after_insert_drug
AFTER INSERT ON drugs
FOR EACH ROW
BEGIN
    CALL insert_drug_with_expiry(
        NEW.NAME,
        NEW.CODE,
        NEW.QUANTITY,
        NEW.PRODUCTION_DATE,
        NEW.EXPIRATION_DATE
    );
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE insert_drug_with_expiry(
    IN p_name VARCHAR(50),
    IN p_code VARCHAR(20),
    IN p_quantity INT,
    IN p_production_date DATE,
    IN p_expiration_date DATE
)
BEGIN
    INSERT INTO expiry (PRODUCT_NAME, PRODUCT_CODE, DATE_OF_EXPIRY, QUANTITY_REMAIN)
    VALUES (p_name, p_code, DATE_FORMAT(p_expiration_date, '%Y-%m-%d'), p_quantity);
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER before_insert_drug
BEFORE INSERT ON drugs
FOR EACH ROW
BEGIN
    IF NEW.expiration_date <= NEW.production_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expiration date must be greater than production date';
    END IF;
END;
//
DELIMITER ;


DELIMITER //

CREATE TRIGGER before_delete_drugs
BEFORE DELETE ON drugs
FOR EACH ROW
BEGIN
    DELETE FROM sales WHERE barcode = OLD.barcode;
    DELETE FROM history_sales WHERE barcode = OLD.barcode;
    DELETE FROM expiry WHERE product_code=OLD.barcode;
END;

//

DELIMITER ;

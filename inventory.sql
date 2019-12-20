-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Czas generowania: 20 Gru 2019, 14:00
-- Wersja serwera: 10.4.6-MariaDB
-- Wersja PHP: 7.3.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `redemrp`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `character_inventory`
--

CREATE TABLE `character_inventory` (
  `identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `characterid` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `metainfo` text COLLATE utf8mb4_bin NOT NULL DEFAULT '{}'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

--
-- Zrzut danych tabeli `character_inventory`
--

INSERT INTO `character_inventory` (`identifier`, `characterid`, `itemid`, `amount`, `metainfo`) VALUES
('steam:11000010a43abf1', 1, 1, 12, '{meta:\'test\'}'),
('steam:11000010a43abf1', 2, 1, 12, '{test=true}'),
('steam:11000010a43abf1', 2, 2, 2, '{test=true}'),
('steam:11000010a43abf1', 1, 2, 6, '{}'),
('steam:11000010f6ed4df', 1, 1, 100, '{}');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `items`
--

CREATE TABLE `items` (
  `itemid` int(11) NOT NULL,
  `name` varchar(16) COLLATE utf8mb4_bin NOT NULL,
  `description` varchar(128) COLLATE utf8mb4_bin NOT NULL DEFAULT ' ',
  `weight` int(11) NOT NULL DEFAULT 0,
  `imgsrc` varchar(28) COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

--
-- Zrzut danych tabeli `items`
--

INSERT INTO `items` (`itemid`, `name`, `description`, `weight`, `imgsrc`) VALUES
(1, 'Japko', 'Zajebiste japuszko ', 45, 'items/wide-blade-knife.png'),
(2, 'Kości do gry', 'Można za ich pomocą grać w kości.', 10, 'items/bolas-thrown.png');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`itemid`);

--
-- AUTO_INCREMENT dla tabel zrzutów
--

--
-- AUTO_INCREMENT dla tabeli `items`
--
ALTER TABLE `items`
  MODIFY `itemid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

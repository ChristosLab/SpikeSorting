%  create a channel map file

Nchannels = 128; % number of channels
connected = true(1, Nchannels);
chanMap0ind = [64, 63, 65, 62, 66, 61, 67, 60, 68, 59, 69, 58, 70, 57, 71, 56, 72, 55, 73, 54, 74, 53, 75, 52, 76, 51, 77, 50, 78, 49, 79, 48, 80, 47, 81, 46, 82, 45, 83, 44, 84, 43, 85, 42, 86, 41, 87, 40, 88, 39, 89, 38, 90, 37, 91, 36, 92, 35, 93, 34, 94, 33, 95, 32, 96, 31, 97, 30, 98, 29, 99, 28, 100, 27, 101, 26, 102, 25, 103, 24, 104, 23, 105, 22, 106, 21, 107, 20, 108, 19, 109, 18, 110, 17, 111, 16, 112, 15, 113, 14, 114, 13, 115, 12, 116, 11, 117, 10, 118, 9, 119, 8, 120, 7, 121, 6, 122, 5, 123, 4, 124, 3, 125, 2, 126, 1, 127, 0];
chanMap   = chanMap0ind + 1;

xcoords = [0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3, 0.0, 43.3];
ycoords = [0.0, 25.0, 50.0, 75.0, 100.0, 125.0, 150.0, 175.0, 200.0, 225.0, 250.0, 275.0, 300.0, 325.0, 350.0, 375.0, 400.0, 425.0, 450.0, 475.0, 500.0, 525.0, 550.0, 575.0, 600.0, 625.0, 650.0, 675.0, 700.0, 725.0, 750.0, 775.0, 800.0, 825.0, 850.0, 875.0, 900.0, 925.0, 950.0, 975.0, 1000.0, 1025.0, 1050.0, 1075.0, 1100.0, 1125.0, 1150.0, 1175.0, 1200.0, 1225.0, 1250.0, 1275.0, 1300.0, 1325.0, 1350.0, 1375.0, 1400.0, 1425.0, 1450.0, 1475.0, 1500.0, 1525.0, 1550.0, 1575.0, 1600.0, 1625.0, 1650.0, 1675.0, 1700.0, 1725.0, 1750.0, 1775.0, 1800.0, 1825.0, 1850.0, 1875.0, 1900.0, 1925.0, 1950.0, 1975.0, 2000.0, 2025.0, 2050.0, 2075.0, 2100.0, 2125.0, 2150.0, 2175.0, 2200.0, 2225.0, 2250.0, 2275.0, 2300.0, 2325.0, 2350.0, 2375.0, 2400.0, 2425.0, 2450.0, 2475.0, 2500.0, 2525.0, 2550.0, 2575.0, 2600.0, 2625.0, 2650.0, 2675.0, 2700.0, 2725.0, 2750.0, 2775.0, 2800.0, 2825.0, 2850.0, 2875.0, 2900.0, 2925.0, 2950.0, 2975.0, 3000.0, 3025.0, 3050.0, 3075.0, 3100.0, 3125.0, 3150.0, 3175.0];
kcoords   = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2];

name = 'DA128-2';

save(fullfile('DA128-2_chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'name')

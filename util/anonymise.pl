#!/usr/bin/env perl
#
# Copyright 2010 Tim Rayner, University of Cambridge
# 
# This file is part of ClinStudy::Web.
# 
# ClinStudy::Web is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# ClinStudy::Web is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
#
# Script to anonymise all records in ClinStudy::ORM
#
# $Id$

use strict;
use warnings;

use Getopt::Long;
use ClinStudy::ORM;
use Config::YAML;

# Parse command-line options.
my ( $conffile );
GetOptions(
    "c|config=s" => \$conffile,
);

unless ( $conffile && -r $conffile ) {

    print (<<"USAGE");
Error: configuration file not supplied or unreadable.

Usage: $0 -c <config file>

USAGE

    exit 255;
}

# Get our array of handy names
my @names;
while ( my $line = <DATA> ) {
    chomp $line;
    my @larry = split /\t/, $line, 3;
    push @names, \@larry;
}

# Connect to the two databases.
my $config = Config::YAML->new( config => $conffile );
my $connect_info = $config->{'Model::DB'}->{'connect_info'};
my $schema = ClinStudy::ORM->connect( @$connect_info );

my $patient_rs = $schema->resultset('Patient');

while ( my $p = $patient_rs->next() ) {

    my $i = int(rand( scalar @names ));

    my $name = $names[$i];

    $p->set_column('firstname', $name->[1]);
    $p->set_column('surname'  , $name->[0]);

    my $yob = $name->[2];
    $yob ||= int(rand(100)) + 1900;
    $p->set_column('year_of_birth', $yob);

    my $hospno = int(rand(1000000));
    until ( ! $schema->resultset('Patient')->find({'hospital_id' => $hospno}) ) {
        $hospno++;
    }
    my $triadno = int(rand(100));
    until ( ! $schema->resultset('Patient')->find({'trial_id' => $triadno}) ) {
        $triadno++;
    }
            
    $p->set_column('hospital_id', $hospno );
    $p->set_column('trial_id',    $triadno );

    $schema->txn_do( sub { $p->update(); } );
}

# With thanks to the Blackfeet Genealogy project, http://www.blackfeetgenealogy.com

__DATA__
Abbot	Maggie	1884
Abbot	Nancy	
Abbot	Nellie	1874
Abbot	Sol	1910
Abbott	Nancy	1885
Abbott	Saul	1891
Adam	Fannie	
Adams	Dorothy May	1917
Adams	Emma	
Adams	Fannie	
Adams	Gertrude	1913
Adams	Mary Williamson	
Adams	Matthew	
Adams	Matthew	1911
Adams	Matthew	
Adams	Matthew	
Adams	Matthew	
Adams	Matthew	1889
Adams	Sydney	1912
Adams	Violet Mary	1914
Adams	William	
After Buffalo	Agnes	1895
After Buffalo	Annie	1895
After Buffalo	Catches Him Down	1857
After Buffalo	Cecile	
After Buffalo	Cecile	1914
After Buffalo	Cecile	1898
After Buffalo	Charles	1913
After Buffalo	Charles	
After Buffalo	Charles	
After Buffalo	Charles	1918
After Buffalo	Charles	1892
After Buffalo	Daisy	
After Buffalo	Dick	1916
After Buffalo	Esther	1913
After Buffalo	George	1908
After Buffalo	Henry	1897
After Buffalo	Isabell	1883
After Buffalo	Isabelle	
After Buffalo	James	1900
After Buffalo	Joe	1893
After Buffalo	John	1893
After Buffalo	Joseph	1894
After Buffalo	Josephine	1900
After Buffalo	Josephine	1887
After Buffalo	Louise	1900
After Buffalo	Louise	
After Buffalo	Maggie	1896
After Buffalo	Mary	1914
After Buffalo	Mary	1896
After Buffalo	Mike	1909
After Buffalo	Minnie	1895
After Buffalo	Pete	
After Buffalo	Peter	1863
After Buffalo	Stephen	1912
After Buffalo	Susan	1896
After Buffalo	Tatsey	1902
After Buffalo	William	1908
After Buffalo	Xavier	1892
Ahkahtah	Mary	1869
Aims Back	Emily	1879
Aims Back	George	1897
Aims Back	Maggie	1897
Aims Back	Martha	1892
Aims Back	Mina	1967
Aims Back	Minnie	1899
Aims Back	Thomas	
Aims Back	Thomas	1894
Aimsback	Maggie	
Aksippi	Gertrude	1870
Albertson	Arthur	1882
Albertson	Chris	1898
Albertson	George	1874
Albertson	Jessie	1883
Albertson	Julia	1898
Albertson	Louis	1884
Albertson	Maggie	1859
Albertson	Maggie Chief Tail Feathers Cold Feet	
Albertson	Maggie Cold Feet	
Albertson	Mary	1891
Albertson	Robert	1890
Allen	Eliza	
Allen	H. S.	
Allen	H.S.	
Allen	Henry S.	1884
Allinson	Annie	1901
Allinson	Sallie	
Allison	A. E.	
Allison	Annie	
Allison	Elwood	1917
Allison	Eunice Mary	1916
Allison	James	1895
Allison	Jesse	
Allison	Jessie	
Allison	Lafayette	1894
Allison	Maggie	1886
Allison	Robert	1891
Allison	Robert Quinton	1919
Allison	Sallie	1874
Allison	Wendall	1896
Allison	William	
Allison	William F.	
Allison	William F.	
Allison	William F.	1919
Allison	William F.	1893
Alver	Belle	1880
Alver	Philip	
Alver	Philip	1908
Ammann	Nora Welch	1880
Anderson	Allan Roy	1917
Anderson	Catherine	1913
Anderson	Catherine	1905
Anderson	Collins	1872
Anderson	Collins Jr.	1916
Anderson	Gale	1905
Anderson	Joseph	1902
Anderson	Mary Jane	
Anderson	Mrs.	
Anderson	Mrs. Thomas	
Anderson	Myron Walton	1913
Anderson	Pauline	1908
Anderson	Pearl	
Anderson	Phena	
Anderson	Robert	1900
Anderson	Thelma Martin	
Anderson	Thomas	1914
Anderson	Wilbur	1899
Anspach	G. P.	
Anspach	G.P.	
Anspach	James Grafton	1915
Anspach	Susannah Lenore	1914
Antelope Woman	Mary	1886
Apis Stoki	Child	1877
Apis Stoki	Mrs.	1877
Appuia	Phillip	1884
Archibald	James	1895
Armell	Augustus	
Armelle	August	
Armelle	Augustus	
Armelle	Augustus	
Armelle	Augustus	
Armelle	Augustus	
Armelle	Augustus	
Armelle	Augustus	1909
Armelle	Augustus	1909
Armelle	Cecile	
Armelle	Cecilia	1841
Armelle	Eliza	1868
Armelle	Eliza Samples	1892
Armelle	Emily	
Armelle	Helen	1909
Armelle	Julie	1891
Armelle	Margaret	1825
Armelle	Monic	1837
Armelle	Monica	
Armelle	Susan	
Armstrong	Amelia	1866
Armstrong	Arthur	1902
Armstrong	Asa	1876
Armstrong	Carroll	1896
Armstrong	Coleman	1887
Armstrong	Grace	1884
Armstrong	James	1885
Armstrong	James Stanly	1912
Armstrong	Jessie	1886
Armstrong	John	1900
Armstrong	John Coleman	1916
Armstrong	Lila	1895
Armstrong	Mabel	1905
Armstrong	Neeley	1890
Armstrong	Orrie	1893
Armstrong	Robert	
Armstrong	Robert	
Armstrong	Robert	
Armstrong	Robert	
Armstrong	Robert	1889
Armstrong	Robert Wilson	1914
Armstrong	Stuart	1903
Armstrong	Wilson	1919
Arnoux	A. Monroe	1906
Arnoux	Bell	
Arnoux	Belle	1885
Arnoux	Carl Joseph	1914
Arnoux	Casey Monroe	1917
Arnoux	Edmund	
Arnoux	Edmund	
Arnoux	Edmund	1909
Arnoux	Edmund	1909
Arnoux	Elsie Valentine	1915
Arnoux	Frances	
Arnoux	Francis	1877
Arnoux	George	1883
Arnoux	George Malclom	1908
Arnoux	Gertrude	1903
Arnoux	Henry Lincoln	1919
Arnoux	James	1909
Arnoux	James Ammell	
Arnoux	James M.	1841
Arnoux	John Munroe	1917
Arnoux	Josephine	1849
Arnoux	Maggie	1887
Arnoux	Marion	1881
Arnoux	Marion H.	
Arnoux	Mary Thelma	1911
Arnoux	Melba J.	1913
Arnoux	Mineral	1879
Arnoux	Monroe	1906
Arnoux	Munroe	1906
Arnoux	Susan	1855
Arnoux	Susan J.	
Arnoux	Thelma Josephine	1913
Arnoux	Vivian May	1910
Arrow Maker	Josephine	
Arrow Maker	Maggie	1922
Arrow Maker	Maggie	1892
Arrow Maker	Maggie	1890
Arrow Maker	Mrs.	
Arrow Maker	Susan	1895
Arrow Top Knot	Antoine	
Arrow Top Knot	Cecile	1916
Arrow Top Knot	George	1896
Arrow Top Knot	John	1906
Arrow Top Knot	Joseph	1911
Arrow Top Knot	Josephine	1908
Arrow Top Knot	Josephine	1911
Arrow Top Knot	Louise	1893
Arrow Top Knot	Philip	1886
Arrow Top Knot	Silas	
Arrow Top Knot	Silas	
Arrow Top Knot	Silas	
Arrow Top Knot	Silas	
Arrow Top Knot	Silas	1866
Arrow Top Knot	Silas	1889
Arrow Top	Billy	1890
Arrow Top	Jack	1888
Arrow Top	Mary	
Arrow Top	Philip	
Ashley	Annie	1908
Ashley	Cecile	1909
Ashley	Frank	1907
Ashley	Lelan	
Ashley	Lelen	1872
Ashley	Louis	1896
Ashley	Lucy	
Ashley	Mary	1909
Ashley	Nellie	1896
Ashley	Talaho	
Ashley	Telew	
Ashley	Tilen	
Aslin	Tallo	1863
Aspling	Finette	1898
Aspling	Lillian	
Aspling	Perry	
Aspling	Valerie	1903
Aspring	Lillian	1886
Assiniboine Plate	Alisa	1879
Assiniboine Plate	Ira	1881
Assiniboine Plate	Levi	1877
Assorted Gun	Mary	1874
Aubrey	Alice	1877
Aubrey	Alonzo	1919
Aubrey	Carroll	1895
Aubrey	Charles	
Aubrey	Charles	
Aubrey	Charles	
Aubrey	Charles	1917
Aubrey	Cora	
Aubrey	Dora	1886
Aubrey	Laura	
Aubrey	Laura	
Aubrey	Laura	1884
Aubrey	Laura	1881
Aubrey	Louisa	
Aubrey	Louise	1860
Aubrey	Lucy	1884
Aubrey	Mabel Stuart	
Aubrey	Mae	
Aubrey	May	1891
Aubrey	Nora	1885
Aubrey	Philip	1889
Aubrey	Rose	1878
Aubrey	Shirley	1915
Aubrey	Thomas	1883
Augare	Emmett	1881
Augere	August	1876
Augere	Francis	1887
Augere	Fransis	1909
Augere	Josephine	1909
Augere	Julia	
Augere	Julia Revis	
Augere	Julie Reevis	
Augere	Pete	1909
Augire	Francis	
Augire	Josephine	1891
Austin	Agnes	
Austin	Anthony	1871
Austin	Clarence	1897
Austin	Paul	1867
Austin	Susan	
Austin	William	
Awats	Rose	1879
Bad Marriage	Cecile	1908
Bad Marriage	Cecile	1907
Bad Marriage	Frances	1919
Bad Marriage	Francis	1911
Bad Marriage	Francis	1911
Bad Marriage	James	1889
Bad Marriage	Jeannette	1915
Bad Marriage	Joe	1888
Bad Marriage	Joseph	
Bad Marriage	Josephine	1916
Bad Marriage	Little Fox	1909
Bad Marriage	Louise	1897
Bad Marriage	Maggie	1911
Bad Marriage	Maggie	1891
Bad Marriage	Mary	1913
Bad Marriage	Mary	1906
Bad Marriage	Mary	
Bad Marriage	Mary	1896
Bad Marriage	Peter	1908
Bad Marriage	Rosa	1906
Bad Marriage	Rosa	
Bad Marriage	Rosa	1893
Bad Marriage	Rose	1914
Bad Marriage	Susan Still Smoking	1906
Bad Marriage	Thomas	1897
Bad Marriage	Thomas	
Bad Old Man	Anna	
Bad Old Man	Anna	
Bad Old Man	Anna	
Bad Old Man	Anna	1841
Bad Old Man	Anna	1883
Bad Old Man	Annie	
Bad Old Man	Frank	1911
Bad Old Man	Josephine	1914
Bad Old Man	Josephine	1914
Bad Old Man	Mack	1881
Bad Old Man	Martha	1919
Bad Old Man	Mary	1911
Bad Old Man	Mike	
Bad Old Man	Richard	1908
Bad Temper	Inez	
Bad Temper	Peter	
Bad Woman	Dick	1881
Bailey	Mary	1885
Baird	Gail	1915
Baker	Belle	1883
Baker	Earl Edward	1912
Baker	Francis C.	1909
Baker	Frank	1920
Baker	Frank	
Baker	George	
Baker	Louise	1874
Baker	Mable Opal	1911
Baker	Mary	1891
Bambrun	Mary	
Barlow	Alex	1887
Barlow	Alice	
Barlow	Angeline	1865
Barlow	Doris	
Barlow	Edwin	
Barlow	Ernest	
Barlow	Forest	1893
Barlow	Forrest	1917
Barlow	John	1881
Barlow	Laverne	1898
Barlow	Margaret	1883
Barlow	Marie	1885
Barlow	Robert E.	1919
Barlow	Selma	
Barlow	Virginia F.	1917
Barnes	Fred	
Barnes	Herbert	1907
Barnes	Louise	1891
Barnes	Violet	1911
Barrington	Elgie S.	1915
Bastien	Frank J.B.	1919
Bead Woman	Joseph	1877
Beads	John	1908
Bear Chief Old	Unmarried	1892
Bear Chief	Cecilia	1902
Bear Chief	Edward	1879
Bear Chief	Isabel	
Bear Chief	Isabel	1881
Bear Chief	Isabell F.O.	1907
Bear Chief	John	
Bear Chief	Joseph	1894
Bear Chief	Joseph	1892
Bear Chief	Lizzie	1899
Bear Chief	Maggie	1890
Bear Chief	Mary	1906
Bear Chief	Mary	1910
Bear Chief	Mary	1895
Bear Chief	Sebastion	1894
Bear Chief	Susie	1895
Bear Child	Ben	1893
Bear Child	Hattie	1897
Bear Child	Jack	1905
Bear Child	James	1891
Bear Child	Jessie	1919
Bear Child	Joseph Raymond	1912
Bear Child	Louis	1879
Bear Child	Rosa	1881
Bear Child	Rosa L.	1915
Bear Child	William	1984
Bear Head	Cecilia	1893
Bear Head	Mary	1888
Bear Head	Tom	1891
Bear Hunter	Mary	1887
Bear Leggings	Child	
Bear Leggings	Irvin	
Bear Leggings	James	1895
Bear Leggings	Lucy	1895
Bear Leggings	Lucy	1877
Bear Leggings	Lucy	1878
Bear Leggings	Maggie	1888
Bear Leggings	Mary	1900
Bear Leggings	Mary	1892
Bear Leggings	Peter	1894
Bear Leggings	Rachel	1886
Bear Medicine	Annie	1904
Bear Medicine	Billy	1891
Bear Medicine	Cecile	1922
Bear Medicine	Cecile	1898
Bear Medicine	Cecile	1898
Bear Medicine	Henry	1898
Bear Medicine	John	1886
Bear Medicine	Joseph	1913
Bear Medicine	Louise	1903
Bear Medicine	Maggie	1893
Bear Medicine	Mary	1915
Bear Medicine	Mike	1905
Bear Medicine	Minnie	1907
Bear Medicine	Peter	1892
Bear Medicine	Robert	1896
Bear Medicine	Susie	1911
Bear Paw	Charles	1894
Bear Paw	Jim	1886
Bear Paw	John	1895
Bear Paw	Joseph	1886
Bear Paw	Minnie	1890
Bear Paw	Thomas	1899
Bear Paw	Thomas	
Bear Shoe	Catherine	
Bear Shoe	Daisy	1880
Bear Shoe	Ellen	1878
Bear Shoe	John	1907
Bear Shoe	John	1882
Bear Shoe	Maggie	1905
Bear Shoe	Margaret	1902
Bear Shoe	Margaret	1917
Bear Shoe	Mrs	1878
Bear Shoe	Mrs.	
Bear Skin	Geneva	1879
Bear Skin	James	
Bear Skin	Jim	1876
Bear Skin	Joe	1902
Bear Skin	Martha	1893
Bear Skin	Mary	1887
Bear Woman	Thunder Woman	1909
Bear	Mary	1918
Bear	Norman	1876
Bear	Thomas	1911
Bear	Virginia Marie	1918
Bears Paw	Charles	1895
Beaumont	Janette	1916
Beaumont	May	1918
Beaumont	Richard	1916
Beaver Eyes	Mary	1890
Bell	Jack	
Bell	Mary	1878
Belledeau	Carrol	1892
Belledeau	Edward	1866
Belledeau	Maggie	1889
Belledeau	Virginia	1869
Bennett	George	1899
Bennett	Noble	1899
Berger	Benjamin Smith	1882
Berger	David	
Berger	David Joseph	1915
Berger	Grace Stella	1919
Berger	Henry	1904
Berger	Jennie	1906
Berger	Lawrence Herbert	1917
Berkin	Essie	1913
Berkin	Mrs William F.	
Berkin	Mrs. William F.	
Berkin	William F.	
Berkin	William	F.	
Berry Carrier	Cecile	1891
Berry Carrier	Child	
Berry Carrier	Joseph	
Berry Carrier	Louise	1893
Berry Carrier	Mike	
Berry Child	Alex	1904
Berry Child	Alex	1902
Berry Child	Annie	1896
Berry Child	Isabell	1907
Berry Child	Isabella	1909
Berry Child	James	1906
Berry Child	Joseph	1900
Berry Child	Louise	1901
Berry Child	Mike	1873
Berry Woman	Mary Jane	
Bier	Isabel	1888
Big Beaver	Aaron	1909
Big Beaver	Annie	
Big Beaver	Ed	
Big Beaver	Eddie	1882
Big Beaver	Edward	
Big Beaver	George	1899
Big Beaver	Isabell	1905
Big Beaver	Joseph	1916
Big Beaver	Lucy	1911
Big Beaver	Lucy	
Big Beaver	Maggie	1909
Big Beaver	Mary	1908
Big Beaver	Mrs.	1911
Big Beaver	Nora Luda	
Big Beaver	Rosa Lucy	1910
Big Beaver	Rose	1893
Big Crow	Cecil	1888
Big Crow	Cecile	1905
Big Crow	Emily	1891
Big Crow	Mary	1891
Big Crow	Rosa	1892
Big Head	John	1893
Big Head	Mary	1865
Big Head	Mary	1888
Big Head	Molly	1887
Big Knife	Mary	
Big Lake	Annie	1882
Big Lake	August	1907
Big Lake	Augustine	1903
Big Lake	Blackfoot Woman	1845
Big Lake	Child	
Big Lake	Daniel	1911
Big Lake	David	
Big Lake	Fred	2920
Big Lake	Good Success	1869
Big Lake	Henry	1900
Big Lake	Jack	1907
Big Lake	John	1878
Big Lake	Levi	1901
Big Lake	Mike	
Big Lake	Mike	
Big Lake	Mike	
Big Lake	Mike	
Big Lake	Mike	
Big Lake	Mike	1874
Big Lake	Mike	1911
Big Lake	Millie	1905
Big Lake	Rachel	1879
Big Lodge Pole	Andrew	1914
Big Lodge Pole	Francis	1919
Big Lodge Pole	Frank	1873
Big Lodge Pole	George	1876
Big Lodge Pole	Kate	
Big Lodge Pole	Katie	1890
Big Lodge Pole	Katie R.M.	
Big Lodge Pole	Maria	
Big Lodge Pole	Mary	
Big Lodge Pole	Peter	1911
Big Lodge Pole	Peter Round Man	1884
Big Lodge Pole	Raymond Alex	1907
Big Lodge Pole	Sammy	1879
Big Moon	Tom	1890
Big Mouth Spring	Cecilia	1893
Big Nose	Charlie	1877
Big Plume	Annie	1900
Big Plume	Jerry	1908
Big Plume	Josephine	1882
Big Plume	Josephine Black Boy	1908
Big Plume	Louisa	1893
Big Plume	Oliver	1900
Big Plume	Willie	1905
Big Road	Agnes	1885
Big Road	Angeline	1879
Big Road	Susan	1888
Big Road	Wolf Woman	1898
Big Rock	John	1878
Big Smoke	Annie	1896
Big Smoke	Teddy	1912
Big Spring	Bessie Lahr	
Big Spring	Cecil	1893
Big Spring	John	1872
Big Spring	Miles	1879
Big Spring	William Forest	1919
Big Springs	Bessie Lahr	
Big Top	Agnes	1883
Big Top	Annie	1915
Big Top	Annie	1891
Big Top	Fredrick	1879
Big Top	George	1910
Big Top	James	1874
Big Top	Jeannette	1918
Big Top	Josephine	1911
Big Top	Louise	1907
Big Top	May	1912
Big Wolf Medicine	Lucy	1888
Big Wolf Medicine	Mary Ann	1887
Big Wolf Medicine	Paul	1885
Billedeaux	Alviua Margaret	1915
Billedeaux	Anna	1916
Billedeaux	Carl	
Billedeaux	Carl	
Billedeaux	Carl	
Billedeaux	Carl	
Billedeaux	Carl	
Billedeaux	Carl	1889
Billedeaux	Carl	1916
Billedeaux	Carl	
Billedeaux	Carl J.	
Billedeaux	Celina	1886
Billedeaux	Charles	
Billedeaux	Charles A.	1889
Billedeaux	Cora --Eo	1916
Billedeaux	Donald Benedict	1917
Billedeaux	Eddie	
Billedeaux	Edward	
Billedeaux	Fay Constance	1921
Billedeaux	Francis	1900
Billedeaux	Geneva	1893
Billedeaux	Genevieve	
Billedeaux	Godfrey	1911
Billedeaux	Greeley	
Billedeaux	Greely	1894
Billedeaux	Isaac	1893
Billedeaux	John W.	1911
Billedeaux	Lincoln	1919
Billedeaux	Mabel	1896
Billedeaux	Maggie	
Billedeaux	Maggie G.	
Billedeaux	Mamie	1903
Billedeaux	Martha	1896
Billedeaux	Mary	1888
Billedeaux	Mavis Tilda	1928
Billedeaux	Melvin	1896
Billedeaux	Merland Joseph	1913
Billedeaux	Michel	1901
Billedeaux	Michelle	1909
Billedeaux	Mollie	1889
Billedeaux	Myrtle	1900
Billedeaux	Pershing Wilson	1919
Billedeaux	Reta Geneveve	1923
Billedeaux	Salina	1886
Billedeaux	Selena	1886
Billedeaux	Vernon Mays	1926
Billedeaux	Virginia	1844
Billedeaux	Warren	1892
Billedeaux	William	1888
Billedeaux	William M.	1912
Billedeaux	X	
Billedeaux	Xavier	1860
Billedeaux	Xavier Jr.	1908
Bird Rattle	Elmer	1882
Bird Rattler	Annie	1902
Bird Rattler	Jimmy	1884
Bird Rattler	Joseph	1900
Bird	Agnes	1900
Bird	Anna	1849
Bird	Annie	1877
Bird	Charles	
Bird	Dorothy Velmar	1912
Bird	Earnestine	1914
Bird	Edward	1886
Bird	George	1894
Bird	Helen	1918
Bird	Henry	1895
Bird	Henry Charles	1888
Bird	Inez	1918
Bird	Isabell	1857
Bird	James	1909
Bird	Johnson	1916
Bird	Joseph	1893
Bird	Leo	1916
Bird	Lillian	1919
Bird	Louisa	1874
Bird	Margaret	
Bird	Margaret Burgess	
Bird	Martha	
Bird	Mary	
Bird	Mary	
Bird	Mary	1890
Bird	Mary	1850
Bird	Mattie	
Bird	Mildred	1917
Bird	Millie	
Bird	Nancy Elizabeth	1913
Bird	Oscar	
Bird	Oscar	1897
Bird	Philip	1852
Bird	Rose	1892
Bird	Sam Jr.	
Bird	Sampson	1882
Bird	Sampson Jr.	1915
Bird	Sarah	1884
Bird	Susan	
Bird	Theo B.	1912
Bird	Thomas	
Bird	Thomas	
Bird	Thomas	
Bird	Thomas	
Bird	Thomas	1879
Bird	Thomas	1879
Bird	Thomas	1853
Bite	George	
Bite	Harry	
Bite	Harry	1911
Bite	Harry	1922
Bite	Harry	1885
Bite	Josephine	1892
Bite	Kasey	
Bite	Minnie	1892
Bite	Rosa	
Bite	Rose	
Bite	Thomas	1904
Black Bear	Agnes	1917
Black Bear	John	1872
Black Bear	Lucy	1873
Black Bear	Maggie	1902
Black Bear	Mary	1897
Black Boy	Anthelia	
Black Boy	Charley	1911
Black Boy	Dora	1913
Black Boy	Josephine	
Black Boy	Percy	1915
Black Boy	Reuban	
Black Boy	Reuben	1888
Black Boy	Teressa	
Black Boy	Theresa	
Black Boy	Thresa	
Black Bull	Jennie	1878
Black Bull	Josephine	1922
Black Bull	Josephine	1898
Black Bull	Josephine	1896
Black Bull	Lucy	1899
Black Bull	Lucy	1904
Black Bull	Maggie	1901
Black Bull	Mary	1897
Black Face Man	Josephine	1893
Black Face	Anthelia	1906
Black Face	Dick	1887
Black Face	Josephine	1911
Black Face	Leslie	1916
Black Face	Melvina	1913
Black Face	Peter	1909
Black Face	Rosa	1885
Black Horn	Mary	
Black Looks	Jim	1891
Black Looks	Puss	1893
Black Man	Charles Joseph	1919
Black Man	Fred	1907
Black Man	Frederick	1884
Black Man	Jesse Joseph	1914
Black Man	Maggie	
Black Man	Mary	1917
Black Man	Robert	1908
Black Weasel	Eli	1881
Black Weasel	Ida	1919
Black Weasel	James	1892
Black Weasel	Minnie	1882
Black Weasel	Rosa	
Blackfeet Woman	Johnny	1882
Blackfeet Woman	Mike	1888
Blackfoot Child	Irene	1886
Blackfoot Woman	Charles	1883
Blackfoot Woman	Mary	1894
Blackweasel	Rosa	
Blair	George	1910
Blair	Henry	1901
Blair	Ida	1899
Blair	Lillie	1904
Blair	Minnie	1861
Blake	Frances L. Dunbar	1891
Blasy	John	1916
Blevens	Walker W.	
Blevins	Bud	
Blevions	Alice	1869
Blevions	Amelia	1893
Blevions	Amelia	1856
Blevions	Dan	1883
Blevions	Walker	1882
Blood	Emma C.	1915
Blood	Fannie	
Blood	Fanny	
Blood	Frances	1913
Blood	James	1896
Blood	Jim	1896
Blood	Jim	1862
Blood	John	
Blood	Lizzie	1907
Blood	Lucy	1911
Blood	Mary	1900
Blood	Mollie	1918
Blood	Pollie	1876
Blood	Polly	
Blood	Polly Fanny	
Bob Tail Horse	Annie	1876
Bob Tail Horse	Charlie	1882
Bob Tail Horse	Joe	1884
Bob Tail Horse	John	1878
Boggs	Alta Fay	1919
Boggs	Daniel Charles	
Boggs	Mrs. O. C.	
Boggs	O. C.	
Boggs	Walter Cameron	
Bogy	Tom	1879
Boles	John	
Boles	John J.	1843
Boles	Virginia	1881
Bordeau	Agnes	
Boss Ribs	Annie	1885
Boss Ribs	Cato	1880
Boss Ribs	James	1903
Boss Ribs	Maggie	1895
Bostwick	Aileen	1919
Bostwick	Anna	
Bostwick	Annie	
Bostwick	Annie	
Bostwick	Annie	1897
Bostwick	Annie	1869
Bostwick	 Frank	
Bostwick	Frank	1886
Bostwick	Frank	
Bostwick	Frank	
Bostwick	Frank	
Bostwick	Frank	
Bostwick	Frank	
Bostwick	Frank	
Bostwick	Frank	1840
Bostwick	Frank	1863
Bostwick	Frank B.	
Bostwick	George	
Bostwick	George	1915
Bostwick	George	1916
Bostwick	George	1895
Bostwick	Henry	
Bostwick	Henry	
Bostwick	Henry	1909
Bostwick	Henry	1893
Bostwick	Isabel	1906
Bostwick	James	1901
Bostwick	Jennie	1911
Bostwick	John	1873
Bostwick	Louise	1873
Bostwick	Mary	
Bostwick	Mary Sharp	1873
Bostwick	Victoria	1908
Bostwick	William	1896
Boutier	Alfred	1902
Boutier	Jennie	1901
Boutier	Joseph	1854
Boy Chief	Anthelia	1887
Boy Chief	Clara	
Boy Chief	Clare	1895
Boy Chief	Dennis	
Boy Chief	Dennis	1918
Boy Chief	Dennis	1893
Boy Chief	Emma	1898
Boy Chief	Johnson	1903
Boy Chief	Melvina	1888
Boy Chief	William	1891
Boy Chief	William	1894
Boy Child	Annie	1896
Boy Child	Michael	1873
Boy	Cecile Short Robe	
Boy	James	1911
Boy	Jensen	1889
Boy	Joseph	1918
Boy	Jr.	1847
Boy	Kathrine	1916
Boy	Margaret	1916
Boy	Mary M.	1914
Boy	Oscar	
Boy	Oscar	1911
Boy	Oscar	
Boy	Oscar	1887
Boy	Oscar	1879
Boy	Raymond	1889
Boyle	Francis	1904
Boyle	Jennie	
Boyle	Jennie K.	1880
Boyle	Jennie L.	
Boyle	Marvin Francis	1911
Breckman	Herman	
Bremner	Charlotte	
Bremner	Mary Elizabeth	1921
Brockey	Agnes	
Brockey	Mary	1906
Brocky	Jack	1875
Brocky	Susie	1896
Brown	Alfred	1901
Brown	Alma Odelia	1907
Brown	Aloysius	1909
Brown	Angeline	1906
Brown	Benedict M.	1913
Brown	Bernadine	1907
Brown	Bernice	1907
Brown	Carroll H.	1909
Brown	Catherine	1883
Brown	Cecil William	1908
Brown	Donald J.	1912
Brown	Earl F.	1914
Brown	Edwin	1914
Brown	Edwin John	
Brown	Eileen	1909
Brown	Esther May	1915
Brown	Francis	1877
Brown	Francis L.	
Brown	Geneva	
Brown	Geneva	1869
Brown	Geneva	1869
Brown	Geneva Marie	1919
Brown	Gerusia	1877
Brown	Grace	1874
Brown	Hazel Margarit	1905
Brown	Henry	1910
Brown	Herman	1901
Brown	Herold	1890
Brown	Herold J.	1889
Brown	James	
Brown	James	
Brown	James	
Brown	James	
Brown	James	
Brown	James	1850
Brown	James	
Brown	James	1909
Brown	James William	
Brown	James William Jr.	
Brown	James William Jr.	
Brown	James William Jr.	
Brown	James William Jr.	1872
Brown	James William Jr.	1872
Brown	James William Sr	1868
Brown	James William Sr.	1841
Brown	James Woodrow	1912
Brown	Jana Rita	1918
Brown	Jesse	1882
Brown	Jesse J.	1882
Brown	Jessie	1888
Brown	Joe	
Brown	John H.	
Brown	John Harold	1913
Brown	John Leo	1914
Brown	John Leo	1913
Brown	Joseph	1874
Brown	Joseph K.	1874
Brown	Joseph W.	1897
Brown	Josephine	1880
Brown	Laurence J.	1903
Brown	Leo	1896
Brown	Leo Mc Kinley	1916
Brown	Mary Eileen	1911
Brown	Mary L.	
Brown	Melvina	1911
Brown	Mrs. Edwin John	
Brown	Olive L.	1919
Brown	Olive L.	1919
Brown	Orin S.	1884
Brown	Richard James	1918
Brown	Rose	
Brown	Sarah	1852
Brown	Sarah Adele	
Brown	Sidney	1904
Brown	Theodore	1901
Brown	Vera Marie	1906
Brown	Victoria	1865
Brown	Victoria L.	
Brown	Vincent	1909
Brown	Wesley	1898
Brown	William	1872
Brown	William James Jr.	
Bruce	Alice May	
Bruce	Alta B.	
Bruce	Harold E.	
Bruce	Mrs. Alta B.	
Bruce	Mrs.Alta B.	
Bruneau	Alex	1916
Bruneau	Joseph	1916
Bruno	Annie	1896
Bruno	Harriet	
Bruno	John	
Bruno	Margaret	
Buck	Charles	
Buck	Charles W.	1875
Buck	W.	1908
Buck	Spyna	
Buckland	Enuxis	
Buckland	Roland	
Buckland	Rowland	1879
Buckland	Rowland W.	1879
Buckland	Susan	1883
Buckley	Charles	1896
Buckley	Jerry	1895
Buffalo Child	Mary	
Buffalo Hide	Agnes	1914
Buffalo Hide	Annie	
Buffalo Hide	Cecil	
Buffalo Hide	Charles	1916
Buffalo Hide	James	1906
Buffalo Hide	John	1904
Buffalo Hide	Louise	1919
Buffalo Hide	Maggie	1899
Buffalo Hide	Peter	1912
Buffalo Hide	Peter	1893
Buffalo Hide	William	1891
Buffalo Hides	Mary	1892
Buffalo Painted Lodge	Margaret	
Buffalo Painted Lodge	Margaret	
Buffalo Painted Lodge	Margaret	
Buffalo Painted Lodge	Margaret	
Buffalo Runner	Anna	1879
Buffalo Runner	Annie	1879
Buffalo Runner	Daisy	1876
Buffalo Runner	Daisy	1876
Buffalo Runner	Josephine	1876
Buffalo	Child	
Bull Calf	Annie	1911
Bull Calf	Charley	1889
Bull Calf	Dominica	1912
Bull Calf	Francis Xavier	1913
Bull Calf	Fred	1916
Bull Calf	Geneva	
Bull Calf	Geneva	
Bull Calf	Geneva	1881
Bull Calf	John	1887
Bull Calf	Joseph	1915
Bull Calf	Martha	1897
Bull Calf	Thomas	1918
Bull Child	Agnes	1890
Bull Child	Agnes Kate	1919
Bull Child	Alice	1919
Bull Child	Amy	1912
Bull Child	Annie	
Bull Child	Annie	1883
Bull Child	Annie	1907
Bull Child	Baby	1888
Bull Child	George	
Bull Child	George	
Bull Child	George	
Bull Child	George	1911
Bull Child	George	1891
Bull Child	George	1893
Bull Child	George Jr.	1914
Bull Child	Grace	
Bull Child	Grace	
Bull Child	Grace	
Bull Child	Grace	
Bull Child	Grace	1916
Bull Child	Grace	1876
Bull Child	Henry	1907
Bull Child	James	1898
Bull Child	Joe	1879
Bull Child	John	1897
Bull Child	Joseph	
Bull Child	Joseph Oliver	1909
Bull Child	Louis	1915
Bull Child	Mark	1895
Bull Child	Martha	1915
Bull Child	Mary Georgiane	1912
Bull Child	Mike	1916
Bull Child	Perce	1870
Bull Child	Percy	1911
Bull Child	Puss	1879
Bull Child	Rosella	1911
Bull Child	Seen Before	1902
Bull Child	Suzette	1912
Bull Child	William	1908
Bull Horn	Carry	1882
Bull Horn	David	1888
Bull Horn	Edward	1886
Bull Plume	Agnes	1913
Bull Plume	Annie	1913
Bull Plume	Dan	1878
Bull Plume	Dan Jr.	1918
Bull Plume	Levi J.	1916
Bull Shoe	Annie	1899
Bull Shoe	Big Woman	1870
Bull Shoe	Cecile	
Bull Shoe	Charles	1883
Bull Shoe	Clyde	1872
Bull Shoe	Ellen	1912
Bull Shoe	Eunice	1921
Bull Shoe	Frances	1910
Bull Shoe	Francis	
Bull Shoe	Irene	1903
Bull Shoe	Irene	1907
Bull Shoe	Joe	1903
Bull Shoe	John	1878
Bull Shoe	Joseph	1903
Bull Shoe	Joseph	
Bull Shoe	Joseph	
Bull Shoe	Joseph	1903
Bull Shoe	Joseph	1887
Bull Shoe	Joseph	1874
Bull Shoe	Laura	1915
Bull Shoe	Leo	1919
Bull Shoe	Lizzie	1901
Bull Shoe	Lizzie	1905
Bull Shoe	Martha	1915
Bull Shoe	Mary	1862
Bull Shoe	Nellie	1905
Bull Shoe	Patrick	1887
Bull Shoe	Rosy	1916
Bull	Bill	1868
Bull	Billie	1872
Bull	Genevie	1870
Bull	James	1895
Bull	Jessie	1882
Bull	Jim	
Bull	Joe	1874
Bull	Lucy	1893
Bull	Sarah	1854
Bull	Susie	1869
Bullchild	Agnes	1886
Bullchild	Joseph	1905
Bullchild	Percy	1875
Bunn	Charles	
Burd	Agnes	
Burd	Agnes	1919
Burd	Agnes	1906
Burd	Alice	1906
Burd	Alice	1879
Burd	Andrew	1908
Burd	Andrew	1908
Burd	Anna	
Burd	Annie	
Burd	Arthur Alfred	
Burd	Arthur Alfred	
Burd	Arthur Alfred	1916
Burd	Arthur Alfred	
Burd	Charlie	1890
Burd	Clarence B.	
Burd	Daisy	1874
Burd	Dorothy	1896
Burd	Edward	
Burd	Eloise	1897
Burd	Ethel	1905
Burd	Francis	1918
Burd	George	1908
Burd	Gertrude Donna	1915
Burd	Harry	1908
Burd	Henry	1877
Burd	Henry Louis	1912
Burd	Ira	
Burd	Ira Samuel	1887
Burd	Ira Wilber	1914
Burd	James	1909
Burd	John	
Burd	John	
Burd	John	
Burd	John	1888
Burd	Johnson	1916
Burd	Joseph Alfred	1906
Burd	Julian	1891
Burd	Levi	
Burd	Levi J.	1877
Burd	Liza	
Burd	Louise	
Burd	Louise	
Burd	Louise	
Burd	Louise	1915
Burd	Louise	
Burd	Louise	1900
Burd	Louise	1887
Burd	Mary	
Burd	Mary	
Burd	Mary	
Burd	Mary	
Burd	Mary	1905
Burd	Mary	
Burd	Mary	1889
Burd	Mary V.	
Burd	Mattie	1867
Burd	Millie	1892
Burd	Mollie	1883
Burd	Nancy	1879
Burd	Philip	
Burd	Phillip	
Burd	Phillip	
Burd	Phillip	
Burd	Phillip	1882
Burd	Phoebe	1889
Burd	Samuel	1917
Burd	Samuel	1885
Burd	Susan	1858
Burd	Susie	
Burd	Susie Alfreda	1912
Burd	Thomas	1840
Burd	Thomas Jr.	1916
Burd	Tom	
Burd	Wilma Ira	1914
Burdeau	Agnes	1882
Burdeau	Annie	
Burdeau	Annie	
Burdeau	Annie	
Burdeau	Annie	
Burdeau	Annie	1864
Burdeau	Annie	1910
Burdeau	David	1874
Burdeau	Dora	1895
Burdeau	Edward	1902
Burdeau	George	1905
Burdeau	Isabel	1888
Burdeau	James	1902
Burdeau	Jeanette Pambrun	1914
Burdeau	Louis	1854
Burdeau	Mary Azell	1912
Burdeau	Robert Running Wolf	1913
Burdeau	Theresa	1901
Burgess	Margaret	
Burns	Billie	
Burns	Mamie	1881
Burns	William H.	1916
Bust	Roy	1911
Bust	Walter Howard	1909
Butler	Albert Michael	1919
Butler	Edward	
Butterbaugh	Earl	1916
Butterbaugh	Hugh	1915
Butterbaugh	Hugh M.	1915
Butterfly	Agnes	1903
Butterfly	Annie	1898
Butterfly	Charles	1919
Butterfly	Elmer	1874
Butterfly	George	
Butterfly	Jane	1897
Butterfly	Jane L. P.	1897
Butterfly	Joe	1894
Butterfly	John	
Butterfly	Joseph	
Butterfly	Mary	1910
Butterfly	Mary	1897
Butterfly	Mary	1902
Butterfly	Mary	1902
Butterfly	Mary	1885
Butterfly	Peter	1895
Butterfly	Roy	1914
Butterfly	Seatal	1897
Buxton	Kemper Nomland	1915
Cadotte	Charles	1898
Cadotte	Frances	1907
Cadotte	Ida	1910
Cadotte	Irene	1922
Cadotte	Joseph	1902
Cadotte	Laurence	1912
Cadotte	Lucy	
Cadotte	Martha	
Cadotte	Mary	
Cadotte	Mary	1850
Cadotte	Mary	
Cadotte	Mary	1902
Cadotte	Mary Cold Body	
Cadotte	Pete	
Cadotte	Peter	1896
Cadotte	Peter 1	1909
Cadotte	Peter 2	1873
Cadotte	Rhoda	1896
Caeppie	Angels I	1882
Calder	Isabelle	
Calf Boss Ribs	Annie	
Calf Boss Ribs	Annie	1874
Calf Boss Ribs	Annie	1903
Calf Boss Ribs	Barney	1874
Calf Boss Ribs	Charles	1908
Calf Boss Ribs	Dan	1910
Calf Boss Ribs	Francis	1919
Calf Boss Ribs	James	1917
Calf Boss Ribs	Joe	
Calf Boss Ribs	Joe	1923
Calf Boss Ribs	Joe	1895
Calf Boss Ribs	Joseph	1913
Calf Boss Ribs	Minnie	1892
Calf Looking	Anna	1888
Calf Looking	Cecile	1907
Calf Looking	Joe	1889
Calf Looking	Joseph	1905
Calf Looking	Maggie	
Calf Looking	Maggie	1882
Calf Looking	Paul	
Calf Ribs	Barney	1872
Calf Ribs	Cats	1880
Calf Ribs	Howard	1873
Calf Ribs	Joe	1908
Calf Ribs	John	1873
Calf Ribs	John	1868
Calf Ribs	Rosa	1887
Calf Robe	Albert	1882
Calf Robe	Anna	
Calf Robe	Anna	
Calf Robe	Anna	1905
Calf Robe	Anna	1879
Calf Robe	Anna Albertson	
Calf Robe	Annie	
Calf Robe	Annie	
Calf Robe	Annie	
Calf Robe	Annie	
Calf Robe	Annie	1896
Calf Robe	Annie	1874
Calf Robe	Annie Albertson	1916
Calf Robe	Child	
Calf Robe	Child	
Calf Robe	Emma	1876
Calf Robe	Frank	
Calf Robe	Frank	
Calf Robe	Frank	
Calf Robe	Frank	
Calf Robe	Frank	1873
Calf Robe	George	1907
Calf Robe	Henry	
Calf Robe	Jennette	1873
Calf Robe	Jennie	
Calf Robe	John	1914
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	
Calf Robe	Joseph	1878
Calf Robe	Joseph	1873
Calf Robe	Julia	1911
Calf Robe	Louise	
Calf Robe	Maggie	1911
Calf Robe	Margaret	1915
Calf Robe	Mary	
Calf Robe	Mary	1919
Calf Robe	Mary	1880
Calf Robe	Mary	
Calf Robe	Mary	1906
Calf Robe	Paul	1913
Calf Robe	Richard	
Calf Robe	Richard	
Calf Robe	Richard	
Calf Robe	Richard	
Calf Robe	Richard	1879
Calf Robe	Richard	1878
Calf Robe	Rose Or Maggie	1912
Calf Robe	Rosie	1900
Calf Robe	Samuel	1912
Calf Robe	Snick	1917
Calf Robe	Thomas	
Calf Shield	George	1892
Calf Tail	Annie	
Calf Tail	Cecile	1902
Calf Tail	Charley	1877
Calf Tail	Doleros	
Calf Tail	Dolores	
Calf Tail	Earnest	1887
Calf Tail	George	1911
Calf Tail	Irene	1909
Calf Tail	John	1875
Calf Tail	Johnny	1880
Calf Tail	Joseph	1880
Calf Tail	Martha	1919
Calf Tail	Mary	1894
Calf Tail	Richard	1907
Calf Tail	Stella	1916
Calf Tail	Susan	
Calftail	Dolores	1890
Calftail	Irene	1905
Calftail	John	
Calftail	Richard	1903
Camp	Bertha	1898
Camp	Charles	1902
Camp	Edward	1902
Camp	Frances	1897
Camp	Mamie	1906
Captain Freighter	Alice	1877
Captain Freighter	Dora	1887
Captain Freighter	Emma	1889
Captain Freighter	Lucy	1885
Captain Freighter	Mary	1859
Captain Freighter	Philip	1888
Captain Freighter	Thomas	1882
Captian Freighter	Laura	1881
Captian Freighter	Mary	
Captian Freighter	Rosy	1879
Cardneal	Nels	
Cardneal	Nels	
Cardneal	Nels	
Cardneal	Nels	1857
Carion	Frank	1844
Carion	Joe	1886
Carlson	Charles	1876
Carmelle	Charles	
Carmelle	Minnie	1909
Carmelle	Rena	1877
Carney	Esther	1872
Carrier	Stella	
Carrion	Alphonzo	1888
Carson	Ellis	1881
Carson	Joe	1886
Casooth	Joseph	
Catch And Hold	Alice	1880
Catch And Hold	Billy	1882
Catch And Hold	Dick	1879
Catch And Hold	Henry	1888
Catch And Hold	Jimmy	1884
Catch And Hold	Martha	1873
Catch And Hold	Mary	1875
Catches At Edge Of Water	John	1880
Catching On Top	Francis	1870
Catching On Top	Johnny	1883
Catching On Top	Maggie	1874
Catching On Top	Pete	1862
Cayton	Clara Francis	1913
Cayton	Isabelle	1892
Cayton	Joe	1875
Cayton	Joseph	
Cayton	Mary	
Cayton	Mary	
Cayton	Mary	
Cayton	Mary	
Cayton	Mary	
Cayton	Mary	1881
Cayton	Nancy	1907
Champagne	Louis	1906
Champagne	Mary	
Champine	Annie	1897
Champine	Bessie	
Champine	Billy	1892
Champine	Bussie	1867
Champine	Busy	1906
Champine	Cecile	1905
Champine	Clay	1890
Champine	Frank	1893
Champine	George	1890
Champine	George P.	1894
Champine	Henry	1917
Champine	Irene	1913
Champine	Louie	1866
Champine	Louis	1906
Champine	Louise	
Champine	Lucy	
Champine	Maggie	1894
Champine	Maginis	1870
Champine	Margaret	1916
Champine	Mary	1897
Champine	Mary	1887
Champine	Mary Ann	1911
Champine	Mary Ann	1911
Champine	Michelle	
Champine	Minnie	1909
Champine	Pete	
Champine	Peter	
Champine	Peter	
Champine	Peter	1894
Champine	Peter	1867
Champine	Puss	
Champine	Susan	1871
Champine	Susie	1914
Champine	William	1919
Champine	William	1906
Champlin	Lewis	1871
Charges Both Sides	Joseph	1895
Charges On Both Sides	Jim	1876
Charley	Fannie	
Charlie	Fannie	
Chattin	Anna Violet	1911
Chattin	Ch	
Chattin	Charles	
Chattin	Charles Irvin	1917
Chattin	Lavina Hall	
Chattin	Susie Hale	
Chattin	Vina Hall	
Chattin	William Azel	1913
Chester	Mable	
Chewing Black Bones	Agnes	
Chewing Black Bones	Isabel	1891
Chewing Black Bones	James	1912
Chewing Black Bones	Jamie	1889
Chewing Black Bones	Jennie	1891
Chewing Black Bones	Joseph	1891
Chewing Black Bones	Josephine	1895
Chewing Black Bones	Maggie	1894
Chewing Black Bones	Mary	1907
Chewing Black Bones	Mollie	
Chicken Hawk Woman	Tommy	1871
Chicken Shoe	Frank	1886
Chicken Shoe	Thos	1887
Chicken Wagon	Charley	1887
Chicken Wagon	Frank	1885
Chicken Wagon	Jack	1889
Chicken Wagon	Thomas	1880
Chief All Over	Antoine	1892
Chief All Over	Frank	
Chief All Over	George	1890
Chief All Over	Itherine Althea	1914
Chief All Over	Maggie	1909
Chief All Over	Mary Ashley	1909
Chief All Over	Mary Veronica	1911
Chief All Over	Mildred	1916
Chief All Over	Virginia Frances	1919
Chief Coward	Annie	1880
Chief Coward	Curley	1894
Chief Coward	Isabelle	1892
Chief Coward	Mary	1892
Chief Coward	Victor	1880
Chief Crow	Albert	1885
Chief Crow	Alfred	1902
Chief Crow	Annie	1897
Chief Crow	Child	
Chief Crow	Helen	1905
Chief Crow	James	1878
Chief Crow	Maggie	
Chief Eagle	Isabelle	1859
Chief Eagle	Johnny	
Chief Eagle	Louisa	1874
Chief Eagle	Tommy	1881
Chief Elk	Elda	1852
Chief Elk	John	1870
Chief Elk	Mary	1878
Chief In Middle	Mary	
Chief In The Middle	Child	
Chief In The Middle	Mary	
Chief In The Middle	Mary	
Chief In The Middle	Mary	1873
Chief In The Middle	Mary	
Chief Top Feathers	Maggie	1861
Chipmunk	Rosie	1888
Choat	Josephine	
Choat	Samual	1878
Choate	Fannie	
Choate	Fanny	
Choate	Frank	
Choate	George	1876
Choate	James	
Choate	Jeannette Rattler	1918
Choate	Marcelein	1904
Choate	Marcellus	
Choate	Mary	
Choate	Rosalind	
Choate	Samuel	
Choate	Van Sam	
Choquette	Charles	
Chouquette	Antoine	1855
Chouquette	Charles	1865
Chouquette	Charles Sr.	1819
Chouquette	Charley	
Chouquette	Edward	1891
Chouquette	George	1893
Chouquette	Henry	1867
Chouquette	Jennett	1894
Chouquette	John	1886
Chouquette	Josephine	1897
Chouquette	Josephine	1883
Chouquette	Josephine	1894
Chouquette	Louise	
Chouquette	Louise	
Chouquette	Louise	
Chouquette	Louise	
Chouquette	Louise	
Chouquette	Louise	
Chouquette	Louise	
Chouquette	Louise	1867
Chouquette	Louise	1852
Chouquette	Maggie	1882
Chouquette	Mary	1868
Chouquette	Melinda	1850
Chouquette	Rosa	1879
Chouquette	Rosa Lee	
Chouquette	Rose	
Chouquette	William	1891
Clark	Agnes	1885
Clark	Anna	
Clark	Anna Martina	1914
Clark	Annie	1885
Clark	Annie	1888
Clark	Annie M.	1914
Clark	Dale	
Clark	Edward	
Clark	Edward	1879
Clark	Edwards Collins	1916
Clark	Ella	
Clark	Ella J.	1875
Clark	Florence Agnes	1911
Clark	George	1913
Clark	George	
Clark	George	
Clark	George	
Clark	George	
Clark	George	1886
Clark	Harold	
Clark	Horace J.N.	1854
Clark	Isabelle	1863
Clark	Jim	1883
Clark	John	1881
Clark	Judith	1863
Clark	Louise	
Clark	Malcolm	1877
Clark	Malcolm W.	
Clark	Malcolm J.	
Clark	Malcolm W.	
Clark	Mary	1824
Clark	Millie	
Clark	Robert	1890
Clark	Virgil George	1916
Clark	Virgil George	1917
Clark	William Alexander	1918
Clarke	Agnes	1909
Clarke	Charlotte E.	1909
Clarke	Dale	1916
Clarke	Edward Collins	1916
Clarke	Ella	
Clarke	Harold	
Clarke	Helen P.	1843
Clarke	Horace J.	1851
Clarke	Irene	1916
Clarke	Louise	1868
Clarke	Lucile	1901
Clarke	Malcolm	
Clarke	Malcolm E.	1843
Clarke	Nathan E. Major	1910
Clarke	Nathanial E.	1909
Clarke	Nathaniel E.	
Clean Sweep	Annie	1891
Cleared Up	Mary Ann	1894
Clears Up	George	
Clears Up	Mary	1901
Cleland	Alfredo B.	1917
Cleland	L. C.	
Cleland	Louis Lawson	1915
Cleland	Mrs. C.	
Cloth Woman	Frank	1881
Coat	Harry	1871
Coat	Henry	1882
Coat	Ida	1902
Coat	Jenny	1897
Coat	Louise	1901
Cobell	Alvin Louis	1917
Cobell	Anna	
Cobell	Annie	
Cobell	Archie	1920
Cobell	Bessie	1884
Cobell	Bessie Hale Danens	
Cobell	Clara	1885
Cobell	Dewey	1896
Cobell	Donald Kieth	1919
Cobell	Eliza	
Cobell	Emma	1908
Cobell	Ferdinand	1913
Cobell	Fred	1888
Cobell	George	1880
Cobell	Irvin	1913
Cobell	Isabel	1895
Cobell	Isabell	1896
Cobell	Isabelle	1870
Cobell	James	1872
Cobell	Jeanette	1895
Cobell	Joe	
Cobell	John	
Cobell	Johnny	1885
Cobell	Joseph	1907
Cobell	Joseph	
Cobell	Joseph	
Cobell	Joseph	
Cobell	Joseph	1888
Cobell	Joseph	1882
Cobell	Josephine	
Cobell	Julia	1873
Cobell	Julie	1911
Cobell	Julius	1891
Cobell	Leslie	1914
Cobell	Louis	
Cobell	Louis	
Cobell	Louis	1919
Cobell	Louis	1855
Cobell	Louis	
Cobell	Louise	1919
Cobell	Louise	1893
Cobell	Mary	
Cobell	Mary	
Cobell	Mary	
Cobell	Mary	
Cobell	Mary	1861
Cobell	Mary	1847
Cobell	Mary Elva	1910
Cobell	Mary Rose	
Cobell	Minnie	1919
Cobell	Ora	1908
Cobell	Pete	
Cobell	Peter	1883
Cobell	Thomas	1898
Cobell	Thomas	1882
Cobell	Thomas R.	
Cobell	Tony	1920
Cobell	Trephina	1899
Cobell	William	1900
Coe	Agnes	1892
Coe	Almon B.	1895
Coe	Almon	B	1885
Coe	Charlie	1888
Coe	James	1890
Coe	Janet	
Coe	Jeannette	1887
Coe	Joanna	1889
Cold Body	Cecil	
Cold Body	Lucy	1879
Cold Body	Maggie	
Cold Body	Maggie	
Cold Body	Maggie	
Cold Body	Mary	
Cold Feet	Maggie	
Come By Mistake	Alick	1861
Comes At Night	Agatte	1918
Comes At Night	Billy	1910
Comes At Night	Cecil	1892
Comes At Night	Cecile	1916
Comes At Night	Charles	1894
Comes At Night	Frank	1909
Comes At Night	George Phillip	
Comes At Night	Jack	1906
Comes At Night	James	1896
Comes At Night	James	
Comes At Night	John	1905
Comes At Night	Maggie	1918
Comes At Night	Mike	1905
Comes At Night	Minnie Agnes	1900
Comes At Night	William	1918
Comes In Night	Sallie	1891
Comes In The Night	Frank	1911
Comes In The Night	Jack	1904
Coming In Night	John	1894
Coming In Night	Minnie	1894
Coming Together	Jim	1886
Cone	Fred	1904
Connelly	Angeline	1867
Connelly	Brian	1889
Connelly	Frank	1886
Connelly	Ida	
Connelly	John	1889
Connelly	Mary	1884
Connelly	Rose	
Connelly	Rose	1885
Connelly	Victor	1888
Connolly	Brian	
Connolly	Daniel B.	1917
Connolly	Jean	1918
Connolly	John	
Connolly	Mary	
Connolly	Merle	1913
Connolly	Nora	1919
Connolly	Rosa	
Connolly	Rose	
Conway	Charles	1876
Conway	Daniel W.	1911
Conway	Eva	1900
Conway	Frank	1907
Conway	Frank	1881
Conway	Frank	1881
Conway	Fred	1906
Conway	Fredrick	1872
Conway	Helen	
Conway	Helen Thelma	1915
Conway	Ida	1904
Conway	Ida	1874
Conway	James	898
Conway	Kate	1852
Conway	Laura	1881
Conway	Rachel	1886
Conway	Ursula	1911
Conway	William	1883
Conway	William Francis	1914
Conway	William Sr.	1902
Cook	George	1864
Cook	George W.	
Cook	Henry	1892
Cook	Isabel	
Cook	Isabella	1910
Cook	Isabelle	1893
Cook	Julia	1872
Cook	Loretta	1896
Cook	Lucy	1866
Cook	William	1909
Cooper	Elizabeth	1909
Cooper	Emma 1	1860
Cooper	Emma 2	1897
Cooper	Isaac	
Cooper	Isaac	1904
Cooper	Isaac	
Cooper	Isaac	1904
Cooper	Isabel Starr	
Cooper	Isabelle	1865
Cooper	Mary	1916
Cornoyer	Carline	
Cornoyer	Caroline	1863
Cornoyer	Charles	1909
Covered Person	Annie	1883
Covered Person	Henry	1877
Covered Person	Isabelle	1873
Covered Person	Johnny	1880
Cow Hide Robe	Grace	
Cow Hide Robe	Gracie	
Cow Hide	Rupert	1874
Coyote	Alice	1894
Crane	Emma	1909
Crawford	Daniel	
Crawford	Ellen	1894
Crawford	James	
Crawford	Joseph	
Crawford	Joseph	1877
Crawford	Merland	1907
Crawford	Minnie	1861
Crawford	Nellis William	1898
Crawford	Ollie	1887
Cree Medicine	Cecile	1862
Cree Medicine	Charles	1904
Cree Medicine	Charles	1883
Cree Medicine	Child	
Cree Medicine	Isabelle	1911
Cree Medicine	Joseph	
Cree Medicine	Joseph	1861
Cree Medicine	Joseph	1876
Cree Medicine	Joseph	1893
Cree Medicine	Josephine	1887
Cree Medicine	Maggie	1878
Cree Medicine	Mary	1861
Creeall	Lizette Louise	1909
Creeall	Louis	1909
Creek	Jim	1867
Croff	A. J.	1916
Croff	Arthur	
Croff	Author	1896
Croff	Benjamin	1919
Croff	Buster	1905
Croff	Clara Agnes	1911
Croff	Dick	
Croff	Edward C.	1896
Croff	Ellen Jane	1907
Croff	Emma	1880
Croff	Emma E. 2	1899
Croff	Eva	1897
Croff	George	
Croff	George	
Croff	George	
Croff	George	1905
Croff	George	1878
Croff	George A.	
Croff	George E.	1914
Croff	Harold	1917
Croff	Hattie	1882
Croff	John	
Croff	John	1874
Croff	John P.	
Croff	Kate	
Croff	Lad	1896
Croff	Leonard Frank	1913
Croff	Louese	
Croff	Louise	1895
Croff	Louise	
Croff	Louise	
Croff	Louise	
Croff	Louise	
Croff	Louise	
Croff	Louise	1871
Croff	Louise	1849
Croff	Maggie	
Croff	Margaret	1911
Croff	Mary	
Croff	Raymond I.	1905
Croff	Raymond Isadore	1908
Croff	Richard	1870
Croff	Richard Joseph	1895
Croff	Stanley R.	
Croff	Stella	1900
Croff	William	1876
Croff	William	1872
Croff	William T.	1913
Cross Gun	George	1895
Cross Gun	John	1922
Cross Gun	Kate	1909
Cross Gun	Percy	1896
Cross Guns	Kate	
Cross Guns	Katie	
Cross Guns	Percy	1896
Cross Guns	Rider	
Crow Eyes	Julia	1899
Crow Eyes	Katie	1898
Crow Eyes	William	1895
Crow Gut	Minnie	1877
Culbertson	Fannie	
Cummings	Alfred N.	1920
Curley Bear	Amelia	1892
Curley Bear	Annie	1830
Curley Bear	Cecile	1903
Curley Bear	Charles	1882
Curley Bear	Charley	1882
Curley Bear	Grass Boy	1902
Curley Bear	Jennie	1903
Curley Bear	John	1895
Curley Bear	Julia	1900
Curley Bear	Lizzie	1892
Curley Bear	Philip	1893
Curley Bear	Prando	1888
Curley Bear	Small Woman	1897
Curley Bear	Willie	1895
Cut Bank John	Charley	1886
Cut Bank John	Dick	1883
Cut Bank John	Jerry	1895
Cut Bank John	Joe	1883
Cut Finger	Alice	1887
Cut Finger	Charles	1908
Cut Finger	Ernest	1885
Cut Finger	Florence	1896
Cut Finger	Geneva	1878
Cut Finger	John	1903
Cut Finger	Joseph	1914
Cut Finger	Maggie	1890
Cut Finger	Paul	1887
Cut Finger	Peter	1916
Cut Finger	Rosa	
Cut Finger	Thomas	1894
Cut Finger	Xavier	1901
Cutting Herself	Cecile	1888
Cutting Herself	Cecile	1877
Cutting Herself	Cecile	1913
Cutting Herself	Maggie	1888
Danens	Dorothy	1918
Darling	Louise Culbertson	1882
David	Emile	1888
Davis	Aaron	1887
Davis	Agnes	1893
Davis	Alice	1892
Davis	Archie W.	
Davis	Bryan	1887
Davis	Catherine	1883
Davis	Claude	1903
Davis	Eddie	1879
Davis	Elizabeth	
Davis	Frank	1881
Davis	George	1909
Davis	Harriet	1893
Davis	Harry	1888
Davis	Hattie	1895
Davis	Josephine Hazel	1919
Davis	Louisa	1866
Davis	Louise	
Davis	Mabel	1886
Davis	Mable	1883
Davis	Mary	1875
Davis	Maud	1908
Davis	Maude	1891
Davis	Mollie	1875
Davis	Pearl	
Davis	Sally	1890
Davis	Thomas	1891
Davis	William	1890
Davis	William L.	1860
Davlin	Mollie	1872
Dawson	Andrew 1	1909
Dawson	Andrew 2	1871
Dawson	Erskins	1884
Dawson	Helen	1895
Dawson	Herold	1890
Dawson	Isabel	1861
Dawson	Isabelle	
Dawson	James	1854
Dawson	Lorena	1884
Dawson	Malcolm	1893
Dawson	Mary	1856
Dawson	Mrs. Thomas	
Dawson	Thomas	1861
Dawson	William	1887
Day Rider	Annie	1908
Day Rider	Clara	1917
Day Rider	George	
Day Rider	George	1887
Day Rider	George	
Day Rider	Helen	1877
Day Rider	Jack	1898
Day Rider	James	
Day Rider	Joe	1896
Day Rider	John	
Day Rider	Joseph	
Day Rider	Joseph	
Day Rider	Joseph	1905
Day Rider	Joseph	1892
Day Rider	Josephine	1912
Day Rider	Josephine	1894
Day Rider	Julia	1905
Day Rider	Margaret	
Day Rider	Michael	1872
Day Rider	Mike	1898
Day Rider	Minnie	1897
Day Rider	Monica	1894
Day Rider	Nettie	1918
Day Rider	Oliver	1895
Day Rider	Peter	
Day Rider	Sadie	1916
De Lancy	Charles	1860
De Lancy	Elizabeth	1905
De Lancy	Julia	
De Lancy	Julia	1907
De Lancy	Julia	1869
De Lancy	Richard	
De Lancy	Viola	
De Roche	Annie	1907
De Roche	Benjamin Jr.	1908
De Roche	Charles	1884
De Roche	John	1916
De Roche	John	1874
De Roche	Josephine	1876
De Roche	Julia	1907
De Roche	Margaret	1913
De Roche	Margereat	
De Roche	Mary	
De Roche	Mary	1909
De Roche	Mary	1911
De Roche	May	1913
De Roche	Salley	
De Roche	Sally	1862
De Wolf	Grace	1908
De Wolf	Jennie	1879
De Wolf	Jennie Hall	
De Wolf	Percy	
De Wolfe	Eva	1903
De Wolfe	Evla	1899
De Wolfe	Jennie	
De Wolfe	Maggie	1897
De Wolfe	Percy	
De Wolfe	Persy	
Dechamp	Mary Josephine	1912
Deguire	Agnes	1902
Deguire	Clarence	1906
Deguire	Claud	1910
Deguire	Ethel	1906
Deguire	Florence	1912
Deguire	Geneva	1909
Deguire	Harry	1909
Deguire	Henry	
Deguire	Henry Burd	1877
Deguire	Ida	1911
Deguire	Louise	1904
Deguire	Mary	1906
Deguire	Mederick	1909
Delaney	Annie	1914
Delaney	Charles	1874
Delaney	Emma	1916
Delaney	Fred	1898
Delaney	George	1901
Delaney	Margaret	1916
Delaney	Margaret Marie	1898
Delaney	Mary	1896
Delaney	Matilda	1911
Delaney	Minnie	1907
Delaney	Viola	1879
Delore	Marie	1909
Delore	Obwen	
Demott	Jenny	1884
Demott	Joseph	1886
Demott	Minnie	1883
Denaie	Angeline	
Denaie	Baptiste	
Denaie	Margaret	
Dennis	Charles Percival	
Dennis	Dora	
Dennis	Edward Patrick	1917
Dennis	Lorraine	1915
Dennis	Percy	1881
Denny	Josephine	1919
Deroche	Sally Mary	
Derwine	Charley	1909
Derwine	Selena	1869
Deschamps	Margaret	
Deschamps	Margarete	
Deschamps	Phillip	1909
Deveraux	Elija	
Devereaux	Agnes	1903
Devereaux	Annie	1882
Devereaux	Charles	1881
Devereaux	Charles Joseph	1912
Devereaux	Charles Merlin	
Devereaux	Delia	1911
Devereaux	Edith	
Devereaux	Elijah Jeff	
Devereaux	Elijah Jefferson	
Devereaux	Emma	1891
Devereaux	Henry	1877
Devereaux	Iva Lillian	1906
Devereaux	Jason	1894
Devereaux	Lenore	1879
Devereaux	Lottie May	1905
Devereaux	Mary	
Devereaux	Mary	
Devereaux	Mary	
Devereaux	Mary	
Devereaux	Mary	
Devereaux	Mary	1853
Devereaux	Mary	
Devereaux	Mrs. Charles	1903
Devereaux	Spyna	1876
Devereaux	Violet	1907
Devereaux	Wilson	1918
Devereaux	Winslow	1901
Different Petrified Rock	Cecile	1906
Different Woman	Nellie	1869
Dog Ears	George	1892
Dog Ears	Louise	1875
Dog Ears	Mary	1910
Dog Gun	Henry	1887
Dog Gun	Mary	1869
Dog Taking Gun	Cecila	1888
Dog Taking Gun	Cecile	1913
Dog Taking Gun	Cecilia	1888
Dog Taking Gun	Josephine	1911
Dog Taking Gun	Lucy	1908
Dog Taking Gun	Maria	1909
Dog Taking Gun	Mary	1898
Dog Taking Gun	Minnie	1904
Dog Taking Gun	Mollie	
Dog Taking Gun	Mollie	1918
Dog Taking Gun	Mollie	
Dog Taking Gun	Mollie	1908
Dog Taking Gun	Mollie	
Dog Taking Gun	Mollie	1909
Dog Taking Gun	Mollie	
Dog Taking Gun	Thomas	1903
Dog Taking	Mollie	
Donovan	Frank	
Don't Go Out	Cecile	1916
Don't Go Out	Christine	1915
Don't Go Out	Emanual	1883
Don't Go Out	Emanuel	
Don't Go Out	Isaac	1907
Double Blaze	Frank	1880
Double Blaze	George	1876
Double Blaze	Hamilton	1890
Double Blaze	Jackson	
Double Blaze	Joseph	1887
Double Blaze	Louis	1893
Double Blaze	Oliver	1888
Double Blaze	Richard	1913
Double Chief	Jack	
Double Chief	Jack	
Double Chief	Mary	1886
Double Hits	Frank	1878
Double Hitter	Charlie	1882
Double Hitter	Frank	1889
Double Hitter	Maggie	1872
Double Hitter	Martha	1859
Double Hitter	Mary	1882
Double Hitter	William	1876
Double Iron Woman	Sandy	1880
Double Jackson	Richard	1898
Double Rider	Ada	1906
Double Rider	Addie	1890
Double Rider	John	1883
Double Rider	Joseph	1899
Double Rider	Mary	1875
Double Rider	Minnie	1893
Double Rider	Minnie	1896
Double Runner	Cecile	1909
Double Runner	Edgar	1877
Double Runner	Edward	78
Double Runner	Edward Gold	1918
Double Runner	Edward Patrick	1917
Double Runner	Isabel	
Double Runner	Mabel	1912
Double Runner	Minnie	1889
Double Runner	Paul	1892
Double Runner	Rosa	1906
Double Runner	Rose	1892
Double Runner	Vincent	1918
Double Walker	Jim	1886
Double Wolf	Louis	1892
Douglas	Agnes	1900
Douglas	Annie	1897
Douglas	Archibald	1894
Douglas	Arthur	1898
Douglas	Cherry	1889
Douglas	Doratha	1910
Douglas	Ernest Benfield	1915
Douglas	Florence	
Douglas	Florence	
Douglas	Florence	1897
Douglas	Florence	
Douglas	Florence Lillian	1912
Douglas	Fransis	1906
Douglas	Grace	1902
Douglas	James	
Douglas	James	
Douglas	James	1895
Douglas	James	1871
Douglas	Jim	
Douglas	John	1877
Douglas	Julia	1908
Douglas	Julia	1886
Douglas	Lavaune	1918
Douglas	Leo	1913
Douglas	Lida	1886
Douglas	Martha	1900
Douglas	Martha	1902
Douglas	Mary	
Douglas	Mary	1899
Douglas	Mary	1856
Douglas	Mary Croff Hassan	
Douglas	Mary Croff Hassen	
Douglas	Mary M.	1916
Douglas	Millie	1878
Douglas	Minnie	
Douglas	Minnie	
Douglas	Minnie	
Douglas	Minnie	
Douglas	Minnie	
Douglas	Minnie	1906
Douglas	Minnie	1873
Douglas	Mollie	
Douglas	Mrs. William	
Douglas	Norma	1907
Douglas	Pauline	1904
Douglas	Pete	1904
Douglas	Peter	1869
Douglas	Raymond	1904
Douglas	Reuben Lawrence	1911
Douglas	Robert	1908
Douglas	Robert	1879
Douglas	Rose	1884
Douglas	Sarah La Von	
Douglas	Theodore	1907
Douglas	Theodore	1889
Douglas	William	1874
Douglas	Woodrow	1916
Douglas	Wright Pershing	1918
Drags His Robe	Susie	1892
Dry Limb	Joseph	1899
Dry Limb	Middle Chief	1903
Dubray	Alex	
Dubray	Alexander	
Dubray	Carl Thomas	1911
Dubray	Douglas	
Dubray	Eva	1900
Dubray	Florence	
Dubray	George	1897
Dubray	Grace	1915
Dubray	Hubert Ray	1915
Dubray	James	1907
Dubray	John A.	1899
Dubray	Joseph	1896
Dubray	Katherine	1910
Dubray	Lester	1908
Dubray	Lillian	
Dubray	Lilly	
Dubray	Mary	
Dubray	Mrs.	
Dubray	Mrs. Alex	
Dubray	Norma	
Dubray	Raymond	
Dubray	Rupert	
Dubrey	Elick	1867
Duck Head	Busy	
Duck Head	Frank	1893
Duck Head	George	1898
Duck Head	George	1890
Duck Head	Josephine	1888
Duck Head	Lizzie	
Duck Head	Louise	1898
Duck Head	Mary	1897
Duck Head	Peter	
Dunbar	Andrew	1890
Dunbar	Carrie	1894
Dunbar	David H.	1912
Dunbar	Esther	1896
Dunbar	Florence	1903
Dunbar	Florence M.	
Dunbar	Frances	1889
Dunbar	Frankie	1892
Dunbar	Hazel	1898
Dunbar	James	1895
Dunbar	Jane	1888
Dunbar	Katherine	1914
Dunbar	Laura	1919
Dunbar	Mary	1872
Dunbar	Mary Jane	1908
Dunbar	Mary L.	1908
Dunbar	Mary O.	
Dunbar	Phoebe	
Dunbar	Phoebe S.	
Dunbar	Sam	1861
Dunbar	Sam B.	
Dunbar	Samual	1887
Dunbar	Tom H.	1905
Dunbar	Vernon	1915
Dunbar	William	
Duncan	Dorothy Verne	1918
Dunlap	Barbara	1909
Dunlap	Hugh	1909
Dusty Bull	Alfreda	1912
Dusty Bull	Anthony	1915
Dusty Bull	Charles	1881
Dusty Bull	Herman	1875
Dusty Bull	Herman Jr.	1906
Dusty Bull	Lily	1910
Dusty Bull	Louise	1881
Dusty Bull	Mary	
Dusty Bull	Mary	1869
Dusty Bull	Minnie	1868
Dusty Bull	Mollie	1878
Dusty Bull	Molly	
Dusty Bull	Nellie	
Dusty Bull	Noble	1915
Dusty Bull	Ralph	1898
Dusty Bull	Roselle	1904
Dusty Bull	Thomas	1895
Duval	Cecilia	1872
Duval	Charles	
Duval	Charles	
Duval	Charles	
Duval	Charles	1884
Duval	Charles	1877
Duval	David	1911
Duval	David	1909
Duval	David	
Duval	David	1878
Duval	David	1878
Duval	Gretchen	1872
Duval	Lillian	1881
Duval	Louise	1863
Duval	Maggie	1882
Duval	Minnie	1873
Duvall	Louise 459641g32 Yellow Bird	
Dwarf Woman	Annie	1880
Eagle Child	Charles	1893
Eagle Child	Emma	1894
Eagle Child	George	1897
Eagle Child	James	
Eagle Child	Joseph	1919
Eagle Child	Mary	1900
Eagle Child	Paul	1903
Eagle Child	Susan	1883
Eagle Flag	Annie	1888
Eagle Flag	Stella	1885
Eagle Head	James	1886
Eagle Head	Jim	
Eagle Head	Johnny	1876
Eagle Head	Maggie	
Eagle Head	Mary	1886
Eagle Head	Rose	1837
Eagle Head	Thomas	
Eagle Ribs	Cecile	1897
Eagle Ribs	Jack	1888
Eagle Ribs	Jennie	1879
Eagle Ribs	John	1879
Eagle Ribs	Louise	
Eagle Ribs	Louise	
Eagle Ribs	Louise	1893
Eagle Ribs	Louise	
Eagle Ribs	Mary	1881
Eagle Ribs	Peggy	1892
Eagle Ribs	Susy	1889
Eagle Tail Feathers	Agnes	
Eagle Tail Feathers	James	1911
Eagle	Peter	1867
Ear Ring	Baby	1912
Ear Ring	Bird	1886
Ear Ring	Susette	1861
Ear Rings	Adam	1885
Ear Rings	Agnes	1910
Ear Rings	Alice May	1912
Ear Rings	Alloysius	1910
Ear Rings	Bird John	1906
Ear Rings	Cathryn	1917
Ear Rings	James	
Ear Rings	James	
Ear Rings	James	
Ear Rings	James	
Ear Rings	James	1881
Ear Rings	James	1842
Ear Rings	John	1906
Ear Rings	Joseph	1907
Ear Rings	Josephine	1905
Ear Rings	Josie	1858
Ear Rings	Maggie	1890
Ear Rings	Mary	
Ear Rings	Mary	
Ear Rings	Mary	1914
Ear Rings	Mary	1867
Ear Rings	Melvin	1906
Ear Rings	Patrick	1914
Ear Rings	Susan	
Ear Rings	Susie	1839
Eats Alone	George Jr.	1911
Edwards	Ela	1914
Edwards	Elizabeth	1895
Edwards	Ellen	1864
Edwards	Evla	1914
Edwards	Fanny	1893
Edwards	Frank	1891
Edwards	George	
Edwards	George	
Edwards	George	1902
Edwards	George	1911
Edwards	Isabelle	1912
Edwards	John	1894
Edwards	Laura	1912
Edwards	Lizzie	1916
Edwards	Louisa	1892
Edwards	Maggie	1896
Edwards	Maud	1889
Edwards	Rose	1894
Edwards	Thomas	1889
Edwards	Virginia	1916
Edwards	William	1889
Eldredge	John	
Eldridge	Emily	1868
Eldridge	John	1893
Ell	Alda	1878
Ell	Annie	1917
Ell	Charles	1895
Ell	Edith May	1913
Ell	George	1907
Ell	Louis	1874
Ell	Louise	1907
Ell	Mary	
Ell	Mary Ann	1911
Ell	Salina	1905
Ell	Samuel	1915
Ell	William	1901
Ellis	Martha	1879
Ellis	Mary	1850
Ellis	William	1873
Embody	Althea Isabelle	1914
Embody	Bert	
Embody	Bertha	1902
Embody	Elmer Floyd	1913
Embody	Harvey Stewart	1918
Embody	Noyes	
Embody	Noyes H.	
Eno	Econ	1881
Eno	Maggie	1865
Eno	Rosie	1876
Eno	Steve	1879
Espinosa	Juanita	1870
Evans	Aloyusis	1907
Evans	Annie	1875
Evans	Cecelia	1879
Evans	Clara	
Evans	Frank	1904
Evans	Hannah	1909
Evans	Hannah	1876
Evans	Henry	1911
Evans	Herman	
Evans	Hirman	1909
Evans	Irene	1899
Evans	James	1896
Evans	Joe	1895
Evans	Joseph	
Evans	Joseph	
Evans	Joseph	
Evans	Joseph	1895
Evans	Joseph	
Evans	Joseph	1895
Evans	Joseph	1873
Evans	Joseph	1876
Evans	Julia	1876
Evans	Mary	1881
Evans	Mary C.	
Evans	William	1906
Everybody Taks About	George	1912
Everybody Talks About	Antoine	
Everybody Talks About	Charles	1916
Everybody Talks About	Emma	
Everybody Talks About	George	1893
Everybody Talks About	Louis	
Everybody Talks About	Mary	1880
Everybody Talks About	Mary Jane	1879
Everybody Talks About	Susan	1895
Everybody Talks About	William	
Everybody Talks	Johnny	1889
Extravagant Person	Mary	
Faber	Anna	1878
Faber	Annie	
Faber	Ellen	1886
Faber	Helen	1912
Faber	Joe	1907
Faber	Laurence	
Faber	Lawrence	1874
Faber	Lizzie	1900
Faber	Louise	1912
Faber	Paul	1902
Fable	Louie	
Fable	Mary	1887
Fable	Rose	
Fallon	Robert Merritt	1912
Fast Buffalo Horse	Able	1882
Fast Buffalo Horse	Albert	1876
Fast Buffalo Horse	Annie	1913
Fast Buffalo Horse	Annie	1912
Fast Buffalo Horse	Anthony	1854
Fast Buffalo Horse	Arthur	1914
Fast Buffalo Horse	Deer	1886
Fast Buffalo Horse	James	1906
Fast Buffalo Horse	Josephine	1887
Fast Buffalo Horse	Julia	1900
Fast Buffalo Horse	Louise	
Fast Buffalo Horse	Mary	1870
Fast Buffalo Horse	Oliver	1870
Fast Buffalo Horse	Sam	1906
Favel	John	
Favel	Lily Whitford	
Fell No Kidney	Mack	1893
Fell No Kidney	Minnie	1877
Fergerson	James	1916
Ferguson	James	
Ferguson	Sarah Monroe	
Fine Bull	Elizabeth	1905
Fine Bull	James	1895
Fine Bull	Lucy	1893
Fine Bull	Maggie	1899
Fine Bull	Rose	1895
Fine Gun Woman	Nellie Abbott Parker	1891
Fine Massacre	Annie	
Fine Shield	Tommy	1884
Finley	Joseph	1909
Finley	Julia	
First Killer	Agnes	1885
First Kills	Ben	1894
First Kills	Mary	1891
First One Russell	Catherine	1913
First One	Louise	1874
First Rider	Rene	1878
Fish	"John"	1912
Fish	Louis	1914
Fish	Louis	1914
Fish	Mary Anna	1919
Fish	Peter	1917
Fish	William	
Fish	William	
Fish	William	1902
Fish	William	
Fisher	Anna	1849
Fisher	Eugene	1896
Fisher	Henry	1900
Fisher	James	
Fisher	James Jr.	1888
Fisher	Jennette	1919
Fisher	Wesley Lewis	1917
Fitzpatick	Lloyd	1901
Fitzpatrick	Bernice	1916
Fitzpatrick	Bernice Kipp	
Fitzpatrick	Dan	1873
Fitzpatrick	Elizabeth	
Fitzpatrick	Elizabeth W.	1876
Fitzpatrick	Hazel	1902
Fitzpatrick	Helen	1899
Fitzpatrick	Herbert	1916
Fitzpatrick	James	1898
Fitzpatrick	Kate	1876
Fitzpatrick	Lorraine	1918
Fitzpatrick	March	1912
Fitzpatrick	Martin	1908
Fitzpatrick	Martin	1914
Fitzpatrick	Matthew	1869
Fitzpatrick	Maud	
Fitzpatrick	Rose	1900
Fitzpatrick	Ursula	
Fitzpatrick	William	
Fitzpatrick	William Kipp	1874
Fitzpatrick	Wilmar	1889
Flamand	Cecile	1918
Flammond	Agnes	1916
Flammond	Robert	
Flammond	Sarah Lewis	
Flat Tail	Agnes	1910
Flat Tail	Annie	
Flat Tail	Annie	
Flat Tail	Annie	
Flat Tail	Annie	1881
Flat Tail	Annie	1898
Flat Tail	Charles	
Flat Tail	Chester	1919
Flat Tail	Felix	1905
Flat Tail	George	1900
Flat Tail	George	1891
Flat Tail	James	1896
Flat Tail	Janette	1914
Flat Tail	Joe	1912
Flat Tail	John	1892
Flat Tail	Josephine	1903
Flat Tail	Louis Thomas	1916
Flat Tail	Philip	
Flat Tail	Phillip	
Flat Tail	Sofa	1893
Flat Tail	Sophia	1892
Flint Smoker	Peter	1885
Flint	Katherine Eleanor	1914
Florestine	Corbett	1895
Florestine	Daniel	1891
Florestine	Ellen	1887
Florestine	Joe	1892
Florestine	Mary	1889
Florestine	Samuel	1894
Ford	Adelle	1884
Ford	Annie	
Ford	Henry	1859
Ford	John	1892
Ford	Joseph	1871
Ford	Mary	1894
Foreign Woman	Mary	1855
Found A Gun	Joseph	1906
Found A Gun	Magge	
Found A Gun	Maggie	1888
Found A Gun	Minnie	1911
Found A Gun	Nancy	1915
Found A Gun	Paul	
Found A Gun	Rosa	1917
Found A Gun	Thomas	1919
Four Horns	Ben	
Four Horns	Benjamin	1880
Four Horns	Charles	1883
Four Horns	George	1880
Four Horns	Hellen	1877
Four Horns	James	1891
Four Horns	Louis	
Fox	Alex	1880
Fox	Alex A.	
Fox	Amelia	1837
Fox	Eliza	1883
Fox	Estella	1912
Fox	Harry A.	
Fox	Lou	
Fox	Mabel	1908
Fox	Maggie	1867
Fox	Millie Monroe	
Fox	Mrs. Lou	
Fox	Myrtle	
Fox	Rosa	
Frazier	Willie	1910
Frisbee	Clarence	1914
Gabraith	Sadie	
Gainer	Pierre	1909
Galbraith	Annie	1891
Galbraith	Eliza	
Galbraith	Elizabeth	1987
Galbraith	Galen George	1913
Galbraith	John	1854
Galbraith	John Jackson	1885
Galbraith	John J.	
Galbraith	John Jackson	
Galbraith	John Spencer	1874
Galbraith	Josephine	1880
Galbraith	Lizzie	1885
Galbraith	Mary	1887
Galbraith	Nedra Marie	1914
Galbraith	Nora	1888
Galbraith	Sadie	
Galbraith	Susie	
Galbraith	Webster	1883
Galbreath	Annie	1891
Galbreath	Eliza	
Galbreath	John	1910
Galbreath	John G.	1846
Galbreath	John J.	
Galbreath	John J. Jr.	
Galbreath	John J.Ackson	
Galbreath	John Jackson	1948
Galbreath	John Spencer	
Galbreath	Kennith H.	1911
Galbreath	Montana Alberta	1909
Galbreath	Reed Leroy	1916
Galbreath	Samual	1831
Galbreath	Samuel	
Galbreath	Susie	
Galbreath	Susie H.	
Gallagher	Cora	1918
Gallagher	John	
Gallagher	John	
Gallagher	John	
Gallagher	John	
Gallagher	John	
Gallagher	Joseph	1913
Gallineau	Cecile	1899
Gallineau	James	
Gallineau	Joseph	1906
Gallineau	Mary	1870
Gallineau	Tom	1915
Gallineaux	James	
Gallineaux	James Pambrun	1866
Gallineaux	John P.	1911
Gallineaux	Mary P.	
Gambler	Alice	1911
Gambler	Anna	1876
Gambler	Annie	
Gambler	Bessie	
Gambler	Cecile	
Gambler	Cecile	1876
Gambler	Desk	1882
Gambler	George	1877
Gambler	Isabel	1881
Gambler	James	1875
Gambler	Jennette	1907
Gambler	Jessie	1873
Gambler	Jessie Pepion	1897
Gambler	Josephine	1915
Gambler	Katie	1904
Gambler	Louisa	
Gambler	Louise	1863
Gambler	Lucy	1905
Gambler	Mary	1899
Gambler	Susie	1903
Gambler	William	1895
Gambler	William	1894
Gardineaux	Jerry	1909
Garnex	Pierre	
Gaurdipee	Eli	
Gerard	Fred	1872
Gerard	Fred Jr.	1910
Gerard	Fred Jr.	1910
Gerard	Fred L.	
Gerard	Hazel	1913
Gerard	Henry	1913
Gerard	James	1919
Gerard	Lydia Rose	1916
Gerard	Mary	1902
Gerard	Rose	1883
Gerard	Rosie	
Ghost	Frank	1876
Gilham	Anthony Charles	1889
Gilham	Clarence	
Gilham	Eleonor Winnifred	1916
Gilham	Evelyn May	1912
Gilham	Herbert Daniel	1916
Gilham	Iola	1914
Gilham	Josephine	
Gilham	Josephine Cobell	1870
Gilham	Julia	1890
Gilham	Myrtle	
Gilham	William	
Gilham	William	
Gilham	William	
Gilham	William	
Gilham	William	
Gilham	William	
Gilham	William	1944
Gilham	William	1916
Gilham	William Herbert	1916
Gladstone	Nellie Thelma	1917
Gobert	Abbie	1891
Gobert	Aggie	1885
Gobert	Agnes	1887
Gobert	Alice	1895
Gobert	Anna	1909
Gobert	Anna M.	1911
Gobert	Annie	1887
Gobert	Catherine	1917
Gobert	Cathrine	1883
Gobert	Charlotte	1904
Gobert	Eddie-Michael	1906
Gobert	Edward	1880
Gobert	Irvine	1898
Gobert	John	1879
Gobert	John L.	1916
Gobert	John Rock	
Gobert	John L.	1916
Gobert	Louise	
Gobert	Margaret	1855
Gobert	Margret	1869
Gobert	Mary	
Gobert	Mary	
Gobert	Mary	1917
Gobert	Mary	1899
Gobert	Mary	1910
Gobert	Maude	1906
Gobert	Mollie	1890
Gobert	Nellie	1897
Gobert	Rock	1869
Gobert	Susan	1877
Gobert	William R.	1904
Goes In All Around	Joseph	1891
Going To Move	James	
Goings	Frank	1908
Goings	Joe	1916
Good Clean Up	Louisa	1894
Good Clean Up	Mary	1881
Good Cleaning Up	Jim	1883
Good Cleaning Up	John	1879
Good Cleanup	Mary Anne	1891
Good Go In	Ella	1874
Good Go In	Gracie	1880
Good Go In	Joseph	1871
Good Gun	Annie	1917
Good Gun	Annie	1883
Good Gun	Cecile	1894
Good Gun	Charley	1880
Good Gun	Francis	1910
Good Gun	Henry	1877
Good Gun	Mollie	1873
Good Killer	Josephine	1884
Good Killer	Maggie	1878
Good Killer	Rosy	1880
Good Killer	Tally	1886
Good Stab	Anna	1893
Good Stabbing	Joe	1907
Good Stabbing	Mary	
Good Woman	Mary	1870
Goss	Abbott	
Goss	Abbott S.	1893
Goss	Agnes	1882
Goss	Albert	
Goss	Albert	
Goss	Albert	
Goss	Albert	
Goss	Albert	1896
Goss	Albert	1875
Goss	Alfred Nathan	
Goss	Bodella Agnes	1915
Goss	Caroline	1884
Goss	Clarence L.	1909
Goss	Ellen	1881
Goss	Ellen E.	1909
Goss	Elvira	1898
Goss	Elwin Earl	1918
Goss	Francis	1895
Goss	Francis S.	1839
Goss	Frank	
Goss	George	1913
Goss	George O.	1891
Goss	Grace M.	1904
Goss	Irene	1879
Goss	Irene M.	
Goss	Irene Margaret	1906
Goss	James Abbott	1919
Goss	Lee Ann	1921
Goss	Lena Hagan	1911
Goss	Loamie	1879
Goss	Lomie	
Goss	Louise	1879
Goss	Mamie	1896
Goss	Margaret	
Goss	Margarette	1873
Goss	Margret	
Goss	Margurete	1853
Goss	Mary	
Goss	Mary Jane	1873
Goss	Mollie M.	1888
Goss	Mrs.	
Goss	Mrs. Nathan	
Goss	Nate	
Goss	Nathan	
Goss	Nathan W.	1886
Goss	Orval Vincent	1917
Goss	Owen Vincent	1916
Goss	Susan	
Goss	Susan A.	1887
Goss	Susie	
Goss	Susie Annie	
Goss	Versa	1905
Goss	William	
Goss	William	
Goss	William	
Goss	William	
Goss	William	
Goss	William	1877
Goss	William B.	1909
Goss	William K.	
Goss	William Leslie	1911
Grain Woman	Mattie	
Grant	Cora	1900
Grant	Edith	1901
Grant	Emma	1907
Grant	Gerald	1900
Grant	James	
Grant	James C. Jr.	1875
Grant	James C. Jr.	1897
Grant	James C. Sr	
Grant	James C. Sr.	1908
Grant	James Sr.	
Grant	Jim	1852
Grant	John	1908
Grant	Josephine	1908
Grant	Josephine T.	1908
Grant	Julia	
Grant	Julia	
Grant	Julia	1865
Grant	Maggie	1891
Grant	Mary	
Grant	Mary	1868
Grant	Mary	1888
Grant	Mary Cold Body	
Grant	Matthew F.	1916
Grant	Melvina	1913
Grant	Nellie	1911
Grant	Perry	1910
Grant	Peter	1887
Grant	Peter Oliver	1911
Grant	Richard	
Grant	Richard	
Grant	Richard	1875
Grant	Richard	1877
Grant	Rosa	1880
Grant	Sarah	1909
Grant	Wallace	1906
Green Grass Bull	Emma	
Green Grass Bull	Joseph	1896
Green Grass Bull	Kitty	1890
Green	Emma	1892
Green	Isabelle	1858
Green	Joseph	
Green	Nickademus	1874
Green	Nicodemus	
Gregg	Homer F.V.	
Grosse	Adam	1909
Grosse	Henry	
Grosse	Magdalene	
Ground	Abbie	1918
Ground	Amy	1901
Ground	Anna Rosalie	1912
Ground	Catherine	1907
Ground	Cecile	1903
Ground	Elizabeth	1899
Ground	Emma Pablo Star	
Ground	George	1919
Ground	George	1879
Ground	James	1912
Ground	Jennie	1874
Ground	John	18
Ground	Joseph	1920
Ground	Margaret	1910
Ground	Marie	1917
Ground	Mary	1915
Ground	Myrtle	1914
Ground	Stella	
Ground	Susan	1908
Ground	Vaille Geneveire	1913
Guardipee	Agnes	1896
Guardipee	Albert	1915
Guardipee	Alec	1910
Guardipee	Aleck	
Guardipee	Alex	1864
Guardipee	Andrew	1912
Guardipee	Cecile	1905
Guardipee	Charles	
Guardipee	Charles	
Guardipee	Charles	1910
Guardipee	Charles	
Guardipee	Charles	
Guardipee	Charles	
Guardipee	Charles	
Guardipee	Charles	1900
Guardipee	Charles	1862
Guardipee	Charles E.	1887
Guardipee	Christinia	1910
Guardipee	Christy Paul	1913
Guardipee	Clara	1911
Guardipee	Coleman	1914
Guardipee	David	1915
Guardipee	Eli	
Guardipee	Elix	1863
Guardipee	Ellen	1894
Guardipee	Eva	1918
Guardipee	Eva	
Guardipee	Eva	
Guardipee	Florence Edith	1912
Guardipee	Francis	1882
Guardipee	Frank	
Guardipee	Frank	
Guardipee	Frank	1895
Guardipee	Frank	1895
Guardipee	Frank	1895
Guardipee	Frank	
Guardipee	Frank	1871
Guardipee	Frank	1885
Guardipee	Frank Jr.	1896
Guardipee	George	1912
Guardipee	George	1893
Guardipee	Gladys Louise	1912
Guardipee	Harold	1915
Guardipee	Hattie	70
Guardipee	Hattie	
Guardipee	Hattie	1892
Guardipee	Hattie	1908
Guardipee	Hattie	1906
Guardipee	Henry	1915
Guardipee	Isabelle	
Guardipee	Jack	1908
Guardipee	Jennie	1910
Guardipee	John	1914
Guardipee	John	1893
Guardipee	John	1894
Guardipee	John	1894
Guardipee	John	1882
Guardipee	Joseph	1906
Guardipee	Josephine	
Guardipee	Josephine	
Guardipee	Josephine	1877
Guardipee	Josephine	1890
Guardipee	Julia	1883
Guardipee	Kate	
Guardipee	Katie	
Guardipee	Katie	
Guardipee	Katie	
Guardipee	Katie	1888
Guardipee	Katie	1871
Guardipee	Katie	1883
Guardipee	Laura	1918
Guardipee	Les	
Guardipee	Louis Phil	1914
Guardipee	Louise	
Guardipee	Louise	
Guardipee	Louise	
Guardipee	Louise	1838
Guardipee	Louise	
Guardipee	Louise	1893
Guardipee	Louise	1847
Guardipee	Louise M.	1916
Guardipee	Madeline	
Guardipee	Maggie	1894
Guardipee	Maggie	
Guardipee	Maggie	
Guardipee	Maggie	1896
Guardipee	Maggie	1852
Guardipee	Maggie	1874
Guardipee	Maggie	1874
Guardipee	Mannie	1906
Guardipee	Mary	1898
Guardipee	Mary	
Guardipee	Mary	
Guardipee	Mary	
Guardipee	Mary	1884
Guardipee	Mary	1895
Guardipee	Mary	1884
Guardipee	Melvin Jesse	1906
Guardipee	Minnie	1887
Guardipee	Nancy	1914
Guardipee	Noble	1916
Guardipee	Oliver	1909
Guardipee	Pete	
Guardipee	Peter	1913
Guardipee	Peter	
Guardipee	Peter	1913
Guardipee	Peter	
Guardipee	Peter	
Guardipee	Peter	1859
Guardipee	Peter	1860
Guardipee	Rose	1904
Guardipee	Saddie	
Guardipee	Sadie	
Guardipee	Sadimina	
Guardipee	Sadonia	
Guardipee	Semide	
Guardipee	Thomas	1881
Guardipee	Tom	
Guardipee	Violet	1906
Guardipee	Wayne	1916
Guardipee	Went In Herself	1851
Guardipee	William	1898
Guardipee	Willie	
Guardipee	Wilson	1919
Guardipie	Christinia	1891
Gullick	William	
Hagan	Alice	
Hagan	Christopher	1913
Hagan	Eliza	
Hagan	Ellen	1889
Hagan	Frank	1912
Hagan	George	1913
Hagan	Gerald Amund	1915
Hagan	Henry	
Hagan	Henry	
Hagan	Henry	
Hagan	Henry	1905
Hagan	Henry	1908
Hagan	Henry	1884
Hagan	John	
Hagan	John	
Hagan	John	
Hagan	John	
Hagan	John	
Hagan	John	
Hagan	John	1909
Hagan	Julie	
Hagan	Knute A.	
Hagan	Lizzie	1832
Hagan	Louisa	
Hagan	Louise	1868
Hagan	Louise Marie	1916
Hagan	Louise Mrs.	
Hagan	Maggie	1886
Hagan	Nellie	1889
Hagan	Sadie	1895
Hagan	Sallie	1866
Hagan	Seraphine	1996
Hagan	William	1907
Hagerty	Anna	1909
Hagerty	Daniel	1907
Hagerty	Donald	1900
Hagerty	Jack	1905
Hagerty	Mary	1915
Hagerty	Millie Rose	1905
Hagerty	Orrie	
Hagerty	Pearl	1873
Hagerty	Rosa	1905
Hagerty	Rose	
Hagerty	Roy J.	1914
Hagerty	William	1906
Haggerty	Joe	
Haggerty	John	
Haggerty	Rose	
Haggerty	Roy John	1913
Hairy Coat	Mollie	
Hairy Coat	Molly	1874
Hairy Face	Agnes	1900
Hairy Face	Cecile	
Hairy Face	John	1895
Hairy Face	Joseph	1894
Hairy Face	Joseph	1899
Hairy Face	Lucy	1893
Hairy Face	Mary	1905
Hale	Bessie Cobell	
Hale	Clarence	1905
Hale	John	
Half Breed	Rosa	1888
Hall	Abner	
Hall	Abner	
Hall	Abner	
Hall	Abner	1894
Hall	Abner	
Hall	Annie	1912
Hall	Daisy	
Hall	David	
Hall	Edgar	1899
Hall	Elsie	1917
Hall	George	1915
Hall	Haran	1902
Hall	Jessie	
Hall	John	1857
Hall	John P.	
Hall	Josephine	
Hall	Josephine	
Hall	Josephine	
Hall	Josephine	1893
Hall	Josephine	
Hall	Josephine	1893
Hall	Josephine	
Hall	Josephine	1876
Hall	Lavina	
Hall	Mary	
Hall	Paddy	1893
Hall	Pat	1893
Hall	Roma	1905
Hall	Rose	
Hall	Ruth	1896
Hall	Thomas	
Hall	Vina	1878
Hall	William	
Hamilton	Al	
Hamilton	Al	
Hamilton	Clara	1906
Hamilton	Ella	1874
Hamilton	Grace	1880
Hamilton	Hildegarde	1913
Hamilton	Joseph	1911
Hamilton	Joseph	1870
Hamilton	Lucy	1853
Hamilton	Robert	1871
Hamilton	Robert	1869
Hamilton	Robert J.	
Hamilton	Rosalie	1898
Hamilton	Rose	
Hamilton	Rosie	
Hamilton	Theo.	1896
Hamlin	Dumpehill	
Hamlin	Joe	1877
Hamlin	Xavier	
Hanby	Charles	1906
Hanby	Jessie	
Hanby	Julia	1904
Hanby	Thomas	1883
Hanby	Tom	1907
Hans	Arthur	1912
Hans	Margaret	1913
Hans	Ruth	1915
Hardin	Joseph	1912
Hardwick	Josephine	1871
Hardwick	Thomas	
Harper	Flora	1915
Harper	John Wesley	1910
Harper	Lansing	
Harper	Lansing P.	1914
Harper	Laura Flora	1914
Harper	Roland	1909
Harper	Susan	1879
Harper	Susan Anna	
Harper	Susan Buckland	
Harris	Julia	1859
Harrison	Frank	
Harrison	Frank	
Harrison	Frank	1893
Harrison	Frank	1857
Harrison	George	1895
Harrison	John	
Hartzham	Alex	1861
Harwood	Isabell	1919
Harwood	Jeff	1914
Harwood	Jewell Avalon	1923
Harwood	Jewell Avalon	1917
Harwood	Louis Bertram	1912
Harwood	Mark	1901
Harwood	Marlin	1905
Harwood	Maud	
Harwood	Merlin Alton	1914
Harwood	Mrs. Thomas	
Harwood	Paul	1899
Harwood	Robert	1908
Harwood	Robert Edward	1914
Harwood	Thomas	1878
Harwood	Tom	
Harwood	Tommy	1902
Harwood	Willie	1898
Hassen	Dan	
Hassen	Daniel Patrick	1919
Hassen	Esther Rachel	1911
Hasson	Dan	
Hasson	Earle William	
Hasson	Mrs. Dan	
Hath	Maggie	1887
Hath	Mary	1888
Hath	Mary	1869
Hawk	Clara	
Hawk	Clara Henault	1889
Hawk	Francis Clara	1912
Hawk	Harry	1908
Hawk	Herbert	1908
Hawk	Mary	1909
Hawk	Ray	
Hawk	Raymond	
Hazlett	Agnes	
Hazlett	Ethel May	1916
Hazlett	George Bernard	1912
Hazlett	Isaac	
Hazlett	Isaac N.	
Hazlett	Josephine	1880
Hazlett	Mary	
Hazlett	Mary Jane	1905
Hazlett	Rose	1915
Hazlett	Stuart	
Hazlett	Stuart I.	1884
Hazlett	Stuart Jr.	1918
Hazlett	William	1875
Hazlette	Jack	1876
Hazlette	Mary Jane	1906
Hazlette	Mary Jane Little Blaze	
Head Carrier	Annie	1907
Head Carrier	Child	
Head Carrier	Frances	1902
Head Carrier	Henry	
Head Carrier	Henry	
Head Carrier	Henry	1867
Head Carrier	Isabel	
Head Carrier	John	1880
Head Carrier	John Jr.	1911
Head Carrier	Mary	1908
Head Carrier	Mary	1899
Head Carrier	Mary	1890
Head Carrier	Stanislaus	1905
Head Carrier	Susie	1902
Heavu Runner	Susie	1909
Heavy Breast	Owen	1880
Heavy Breast	Rosa	1876
Heavy Breast	Susan	1891
Heavy Breast	Young	1879
Heavy Face Woman	Bob	1884
Heavy Face Woman	Dora	1884
Heavy Face Woman	Ella	1874
Heavy Face Woman	Johnny	1882
Heavy Face Woman	Kattie	1879
Heavy Face Woman	Libbie	1877
Heavy Face Woman	Mary	1882
Heavy Face Woman	Mary Jane	1873
Heavy Face Woman	Molly	1880
Heavy Gun	Arthur	
Heavy Gun	Cecile	1902
Heavy Gun	Edgar	1870
Heavy Gun	Grace	1878
Heavy Gun	Henry	1874
Heavy Gun	Jack	1900
Heavy Gun	Jessie	1905
Heavy Gun	Josephine	1881
Heavy Gun	Mary	1867
Heavy Gun	Richard	1913
Heavy Gun	William	1904
Heavy Runner	Annie	1908
Heavy Runner	Coyote	1911
Heavy Runner	Dick Kipp	
Heavy Runner	Florence	1916
Heavy Runner	Francis	1919
Heavy Runner	George	1916
Heavy Runner	George	
Heavy Runner	George	
Heavy Runner	George	
Heavy Runner	George	
Heavy Runner	George	
Heavy Runner	George	1911
Heavy Runner	George	1889
Heavy Runner	Ida	1910
Heavy Runner	Jack	1897
Heavy Runner	James	1902
Heavy Runner	Joseph	1889
Heavy Runner	Joseph Jr.	1917
Heavy Runner	Kate	
Heavy Runner	Katie	1896
Heavy Runner	Maggie	1901
Heavy Runner	Mary	
Heavy Runner	Mary	
Heavy Runner	Mary	1888
Heavy Runner	Mary	1895
Heavy Runner	Nora	1919
Heavy Runner	Rosa	1906
Heavy Runner	Rosie	
Heavy Runner	Susan	1894
Heavy Runner	Susie	
Heavy Runner	Tom	1916
Heavy Runner	William	1894
Heavy Runner	Wood	
Henault	Annie	1900
Henault	Clara	1890
Henault	Eliza	1877
Henault	George	1909
Henault	John	
Henault	Lillian	1904
Henault	Louise	1870
Henault	Maggie	1899
Henault	Marian	1902
Henault	Mary	
Henault	Mary	1916
Henault	Mary	1908
Henault	Mary	1855
Henault	Mary	
Henault	Mary	1916
Henault	Moses	1887
Henault	Nelson	1879
Henault	Rose	
Henault	Rosie	1872
Henault	Stephen	1877
Henault	Steven	1899
Henault	Theresa	1878
Henderson	Alice Irene	1913
Henderson	Dorothy	1916
Henderson	James	1912
Henderson	Leslie Orin	1914
Henderson	Lizzie R. Main	1895
Henderson	Pauline	1908
Henkel	Aleen May	1908
Henkel	Audrey	1918
Henkel	Bessie	1880
Henkel	Catherine	
Henkel	Elizabeth	1886
Henkel	George	
Henkel	George Jr.	1919
Henkel	George R.	
Henkel	Henry	1909
Henkel	Henry F.	1879
Henkel	Magdalene	1909
Henkel	Mamie	1888
Henkel	Urban	1909
Henkel	William	
Heran	Maggie	74
Heran	Mary	1890
Hetzer	Harry	
Hetzer	Howard Kenneth	1919
Higghins	Louise	
Higgins	Alice	1887
Higgins	Cathrine	1905
Higgins	Charles	1895
Higgins	David	1898
Higgins	Henry	1884
Higgins	John	
Higgins	Louise	
Higgins	Maggie	1895
Higgins	Mary	
Higgins	Mary	
Higgins	Mary	
Higgins	Mary	1876
Higgins	Mary	1872
Higgins	May	1896
Higgins	Napoleon	1895
Higgins	Patrick	
Higgins	Patrick J.	1864
Higgins	Patrick Jr.	1908
Hill	Dan	
Hill	Dan W.	1916
Hill	Daniel	1893
Hill	Dorothy	1918
Hill	Fred	1891
Hill	Gladys	1916
Hill	Martha	1873
Hilton	Edward Louis	1916
Hilton	Grant	1918
Hilton	John Edward	
Hilton	Pearl Davis	
Hinkel	Lizzie	
Hirst	Allan	
Hirst	Allen	1916
Hirst	Frances Marie	1916
Hirst	John Allan	1918
Hits Back	Joe	1881
Hits Back	Paul	1894
Hits Hard	Martha	1879
Hits In Front	Austin	1887
Hits In Front	Joseph	1880
Hixon	Bertha	
Hixon	Fred	1920
Hixon	Leo Wilbur	1918
Hixon	Leo Wilbur	1917
Hixon	Lucille May	1915
Hixon	Mary	
Hixon	Mary Ann	1879
Home Gun	Annie	1901
Home Gun	Cecile	1915
Home Gun	Daniel	1903
Home Gun	Isabell	1910
Home Gun	Isabelle	1919
Home Gun	James	1898
Home Gun	Joseph	1903
Home Gun	Maggie	1904
Home Gun	Marie	1895
Home Gun	Mary	1887
Home Gun	Mollie	1915
Home Gun	Paul	1892
Home Gun	Peter	1911
Home Gun	Susan	1913
Horan	Annie	1888
Horan	George	1868
Horan	Maggie	1872
Horan	Mary	1888
Horn	Agnes	1902
Horn	Alex	1848
Horn	Charles	
Horn	George	1868
Horn	Harry	1888
Horn	Henry	1874
Horn	John	1912
Horn	Joseph	
Horn	Joseph	1913
Horn	Laurence Richard	1911
Horn	Lavina	1908
Horn	Louise	1908
Horn	Melonis Cecile	1911
Horn	Nancy	
Horn	Nancy	1908
Horn	Rufus	1915
Horn	Susan	1870
Horne	Aleck	1857
Houck	Monick	
Houk	Eleanor	1898
Houk	George	
Houk	Margaret	1885
Houk	Monick	
Houk	Presley	1898
Houk	Pressy	1880
Houseman	Edmund	
Houseman	Edmunds	1909
Houseman	Frank	1892
Houseman	Gevena	1894
Houseman	James	1867
Houseman	Jenivene	1894
Houseman	Joseph	1890
Houseman	Josephine	1896
Houseman	Margaret	
Houseman	Mary	1891
Houseman	Susan	
Houseman	Susan	
Houseman	Susan	
Houseman	Susan	1910
Houseman	Susan	
Houseman	Susan	1866
Houseman	Susie	
Houseman	Thomas	1889
Howard	Anna	1884
Howard	Annie	1887
Howard	Annie D.	
Howard	Annie I	
Howard	Annie I.	
Howard	Edna	1917
Howard	Frank	
Howard	Joseph	1832
Howard	Joseph W.	1876
Howard	Mary	
Howard	Mary	
Howard	Mary	1877
Howard	Mary	1913
Howard	Mary	
Howard	Spina Violet	1908
Howard	Valentine	1915
Howard	Walter	
Howard	Walter	
Howard	Walter	
Howard	Walter	1910
Howard	Walter	1883
Howard	Wilma Ann	1918
Howling	Joseph	1883
Howling	Julia	
Hudson	Douglas Haig	1919
Hudson	Susie	
Hudson	Susie	
Hudson	Susie	
Hudson	Susie	
Hudson	Susie	
Hudson	Susie	1882
Hudson	Theda Anna	1918
Hughes	David E.	1916
Hungry	Agnes	1910
Hungry	Agnes	1910
Hungry	George	1903
Hungry	Harry	1879
Hungry	Henry	1897
Hungry	Hestor	1906
Hungry	Katie	1866
Hungry	Lawrence	1907
Hunsberger	Annie E.	1915
Hunsberger	Augustus	1902
Hunsberger	Clara	1879
Hunsberger	George	1903
Hunsberger	Gus	1882
Hunsberger	Isace	1873
Hunsberger	John	1872
Hunsberger	Martha	1909
Hunsberger	Mary	1898
Hunsberger	Thedora Agnes	1906
Hunsberger	Thomas	1902
Hunsberger	Tom	1876
Hunsberger	William	1901
Hwnderson	James Wilfred	1912
Ingram	Florence S.	1904
Ingram	Henrietta	1906
Ingram	Ida T.	1873
Ingram	James T.	1908
Ingram	Joe	
Ingram	Joseph	
Inman	Edith	1886
Inman	Maggie	1880
Inman	Olive	1888
Iron Breast	Annie	1896
Iron Breast	Annie Martha	1894
Iron Breast	Charles	1878
Iron Breast	Ida	1903
Iron Breast	John	1907
Iron Breast	Nellie	1897
Iron Crow	Isabell	1887
Iron Eater	Annie	1882
Iron Eater	Catherine Bear Shoe	1899
Iron Eater	Daisy	1882
Iron Eater	Isabel	1887
Iron Eater	James	1893
Iron Eater	John	1892
Iron Eater	Joseph	1900
Iron Eater	Josephine	1895
Iron Eater	Lucy	1888
Iron Eater	Nellie	1884
Iron Eater	Paul	1895
Iron Eater	Rosie	
Iron Eater	Susie	1902
Iron Eater	Susie	1876
Iron Eater	Susie	1888
Iron Necklace	Annie	1890
Iron Necklace	Mary	1909
Iron Pipe	Agnes	1899
Iron Pipe	Beaver	1909
Iron Pipe	Cora	1889
Iron Pipe	George	1919
Iron Pipe	Joe	1908
Iron Pipe	John	1893
Iron Pipe	John	1893
Iron Pipe	Joseph	1899
Iron Pipe	Joseph	1886
Iron Pipe	Louis	1896
Iron Pipe	Maggie	1887
Iron Pipe	Mary	1891
Iron Pipe	Paul	1914
Iron Woman	Johnny	1878
Irvin	Fannie	
Irvin	Fannie Culbertson	1854
Irvin	Frances	1906
Irvin	Pierre A.	1886
Jack	Cecila	1902
Jack	Cecile	1891
Jack	Eddie Jr.	1900
Jack	Eddy	1868
Jack	Edward	1871
Jack	Isabelle	1858
Jack	Money	1895
Jackson	Alice	
Jackson	Alice A.	
Jackson	Alva Kale	1914
Jackson	Amelia	1890
Jackson	Andrew	1903
Jackson	Annie	1893
Jackson	Annie Little Plume	
Jackson	Cecile Morning Plume	1912
Jackson	Charles	1904
Jackson	Dorothy R.	1919
Jackson	Double Blaze	
Jackson	Elmer	1904
Jackson	Florence Mad Plume	1896
Jackson	George	1906
Jackson	Grace	
Jackson	Grace A.	
Jackson	Grace A.	
Jackson	Grace A.	
Jackson	Grace A.	
Jackson	Grace A.	1885
Jackson	Grace Lillian	1916
Jackson	Hugh	1888
Jackson	James Wilbur	1911
Jackson	Jimmy	1888
Jackson	Josephine	1916
Jackson	Josephine D.	
Jackson	Julia	1899
Jackson	Maggie	1891
Jackson	Margrate	1893
Jackson	Mary	
Jackson	Mary	
Jackson	Mary	
Jackson	Mary	1894
Jackson	Mary	1862
Jackson	Mary Louise	1912
Jackson	Millie	1915
Jackson	Mrs. William	
Jackson	Thomas	1911
Jackson	Tommy	1885
Jackson	Viola Margaret	1919
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	
Jackson	William	1899
Jackson	William	1909
Jackson	William	1889
Jackson	William	
Jackson	William	1919
Jackson	William	1859
Jackson	William Jr.	
Jackson	William Jr.	1919
Jackson	William Jr.	1883
Jackson	William Jr.	1892
Jackson	Woodrow Charles	1913
Jassieu	Marie	
Johnson	Beatrice	1904
Johnson	Belle	1885
Johnson	Bernice	1908
Johnson	Charlie	1881
Johnson	Dorothy	1897
Johnson	Georgia	1902
Johnson	Harper	1905
Johnson	Helen	1896
Johnson	Homer	1890
Johnson	Ida	
Johnson	Ida	
Johnson	Ida	1889
Johnson	Ida	1889
Johnson	Jennie	
Johnson	Jennie Monroe Murphy	
Johnson	Jenny	1834
Johnson	Jim	1885
Johnson	Mary	1899
Johnson	Mary	1879
Johnson	Neil	1916
Johnson	Sadie	1877
Johnson	Willie	1883
Jose	Cora M	
Jose	Mary	1880
Jumping Jack	Jimmy	1888
Juneau	Alfred Leroy	1919
Juneau	Alice J.	1918
Juneau	Alice Rose	1914
Juneau	Antoine	
Juneau	Charles	1879
Juneau	Charles Benton	1914
Juneau	Emedy	1894
Juneau	Emory	1897
Juneau	Franklin Edvert	1914
Juneau	Josephine	
Juneau	Juanita Grace	1916
Juneau	Mary Black Horn	1846
Juno	Josephine	
Kaiser	Bill	1908
Kaiser	Maggie	1853
Kaiser	Maggie Goss	1873
Kaiser	Mary	
Kaluse	Charles	
Kaluse	Minnie	1889
Keating	Jere	1893
Kemp	Leo Harold	1916
Kennedy	Alvin W.	
Kennedy	Alvin Webster	1916
Kennedy	Esther	1899
Kennedy	John	
Kennedy	John Breckmon	1915
Kennedy	John Jr.	1877
Kennedy	John Sr.	1903
Kennedy	John W.	1898
Kennedy	Lizzie	1914
Kennedy	Mary Bailey	
Kennedy	William	1897
Kennedy	William Walter	1918
Kennerly	Agnes	1886
Kennerly	Bertian	1876
Kennerly	Bertrand Jr.	1914
Kennerly	Carry	1889
Kennerly	Hattie	1884
Kennerly	Henry	1896
Kennerly	James	1896
Kennerly	Jerome	1887
Kennerly	Lee	
Kennerly	Leo	1896
Kennerly	Maggie	
Kennerly	Margaret	1851
Kennerly	Marguerite	1869
Kennerly	Molly	1873
Kennerly	Perry	1879
Kennerly	Sally	1874
Kerr	Hawkins W.	
Kerr	Jennie	1882
Kerr	John W.	1871
Kerr	Mary	
Kerwin	Anne	
Kerwin	Annie	
Kerwin	Robert Graham	1919
Kettle	Charley	
Kettle	Charley	1884
Kettle	Charley	
Kettle	Sally De Roche	
Kicking Woman	Agnes	
Kicking Woman	Cecile	1910
Kicking Woman	Cecile	1906
Kicking Woman	Child	
Kicking Woman	Child	
Kicking Woman	George	1914
Kicking Woman	James	1917
Kicking Woman	James	1904
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	1916
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	
Kicking Woman	John	1879
Kicking Woman	John	1909
Kicking Woman	Joseph	1916
Kicking Woman	Mary	
Kicking Woman	Victoria	1881
Kicking	Victoria	
Kidd	Mary	1869
Kidd	Thomas	1861
Kidd	Willie	1895
Killed In The Lodge	Theresa	1909
Killed Many	Alice	1888
Killed Two	Agnes	1885
Killed Two	Joseph	1891
Kills Across The Way	John	1876
Kills Across The Way	Joseph	1893
Kills Across The Way	Louise	1899
Kills Across The Way	Viola	1919
Kills At Night	Agnes	
Kills In Brush	Mary Jane	1881
Kills In The Brush	Josephine	
Kills In The Brush	Katie	1885
Kills In The Brush	Maggie	1882
Kills In The Brush	Mary	1888
Kills In The Brush	Mary	1888
Kills Last Or Last Kills	Mary	
Kills Last	Mary	
King	Charles	1890
King	Clarence	1904
King	George	1897
King	Henry	1896
King	James	1888
King	Louise	1906
King	Lucy	1863
King	Marguerite	1906
King	Sadie	1885
King	Sherman	1895
King	Wallace	1901
King	Willie	1893
Kipling	Dorothy	
Kipling	Mary	
Kipp	Alfrida	1908
Kipp	Annie	1902
Kipp	Burnice	1900
Kipp	Cecile	
Kipp	Charles	1910
Kipp	Cora	1905
Kipp	Cora Ross	1888
Kipp	Dick	1862
Kipp	Dick 2	1891
Kipp	Dick H. R.	
Kipp	Dora May	1911
Kipp	Elizabeth	
Kipp	Elizabeth	
Kipp	Elizabeth	
Kipp	Elizabeth	1917
Kipp	Elizabeth	1874
Kipp	Ellen	1902
Kipp	Emma	1872
Kipp	Fitzpatrick	1914
Kipp	Genevieve	1915
Kipp	George	1896
Kipp	Grinnell J.	1919
Kipp	Guy	1895
Kipp	Henrietta	1907
Kipp	Isabell	1883
Kipp	Isabella	
Kipp	Isabelle	
Kipp	Jack	1901
Kipp	Jack	1885
Kipp	James	
Kipp	James	
Kipp	James	
Kipp	James	1909
Kipp	James	1890
Kipp	Joe	1875
Kipp	Joe Jr.	
Kipp	John	1861
Kipp	Joseph	1900
Kipp	Joseph 1	
Kipp	Joseph Albert	1914
Kipp	Joseph Carlson	1893
Kipp	Joseph Jr.	1888
Kipp	Julia	1895
Kipp	Louis	1888
Kipp	Maggie	1878
Kipp	Maggie	1877
Kipp	Maggie	1880
Kipp	Martha	
Kipp	Martha	
Kipp	Martha	
Kipp	Martha	1820
Kipp	Martha	1855
Kipp	Mary	
Kipp	Mary	
Kipp	Mary	
Kipp	Mary	
Kipp	Mary	1894
Kipp	Mary	1866
Kipp	Mary H. R.	
Kipp	Sadie	1901
Kipp	Sam	1911
Kipp	Sam	1911
Kipp	Thomas	1901
Kipp	Ursula	1898
Kipp	William	
Kipp	William	
Kipp	William	
Kipp	William	
Kipp	William	1874
Kipp	William	1890
Kipp	William B.	1913
Kipp	William Jr.	1913
Kipp	William Or William Fitzpatrick	
Kipp	Willie Marie	1919
Kiser	Mary	1819
Kitson	Laura	1916
Kittson	Florence	1917
Kittson	Frank	1914
Kittson	Frank	1915
Kittson	Jerry	
Kittson	Julia C.	1915
Kittson	Mary	1888
Kittson	Michael Marshall	1917
Kittson	Mike J.	
Kittson	Rose	1908
Kittson	Thomas Joseph	1911
Kiyo Sr.	Anthony	1875
Kiyo Sr.	Frank	1876
Kiyo Sr.	Josephine	1886
Kiyo Sr.	Louis	1866
Kiyo Sr.	Pete	1874
Kiyo Sr.	Secele	1872
Kiyo	Elix	1847
Kiyo	Eliza	1884
Kiyo	Jennie	1872
Kiyo	Johnny	1886
Kiyo	Louis	1866
Kiyo	Mary	
Kiyo	Mary	
Kiyo	Mary	1874
Kiyo	Mary	1871
Kiyo	Mary	1871
Kiyo	May	1893
Kiyo	Pete	
Kiyo	Thomas	
Kiyo	Tom	1861
Kiyo	William	1895
Klongi	Helena	1908
Klongi	Mollie	70
Klongi	Stephen	
Klongi	Stephen Jr.	1911
Klongie	Mollie	
Kologi	Mollie	
Kologi	Rose Mary	1915
Kologi	Theresa	1912
Kologie	Mollie	
Kologie	Stephen	1911
Kona	Lewis	1909
Kona	William	
Kona	William	
Kossuth	Jose	1875
Kossuth	Louis	
Kossuth	Mary	
Kramer	Robert	
Kuehn	Ella	1948
Kuka	Clarence	1907
Kuka	Frank	1901
Kuka	Henry Clinton	1913
Kuka	Joseph	
Kuka	Joseph Jr.	1918
Kuka	Mabel	1905
Kuka	Martha	1871
Kuka	Mary	1897
Kuka	Merrel	1903
La Barge	Josephine	
La Beouff	Hazel	1918
La Beouff	Henry	
La Boeuff	Henry	
La Boeuff	Jesse	1919
La Breche	Charles	
La Breche	Charles D.	1909
La Breche	David	
La Breche	Earl Joseph	1917
La Breche	Jessie	1887
La Breche	Julia	1871
La Breche	Minnie	
La Breche	Presley P.	1915
La Page	Annie	1869
La Page	Theresa	
La Plant	Edward	1904
La Plant	Frances	1910
La Plant	Hilda May	1912
La Plant	Hilda May	1912
La Plant	Louis	1880
La Plant	Nobel Napoleon	1918
La Plant	Virginia	1903
La Plant	Walter George	1914
Labeouff	Henry	
Labeouff	William	1914
Laboeuff	Henry	1867
Laboeuff	Stephen	1917
Laboeuff	Theresa	
Labreche	Bernice M.	1912
Labreche	Bertha	1884
Labreche	Charles	1896
Labreche	Charles D.	
Labreche	Clarence	1894
Labreche	David	1913
Labreche	Emily	1846
Labreche	George	1901
Labreche	Hester	
Labreche	Jacques	
Labreche	Jessie	1899
Labreche	Julia	1902
Labreche	Lenore	1905
Labreche	Madore	
Labreche	Mary	1908
Labreche	Medora	1902
Labreche	Medore	1902
Labreche	Medore Jr.	1906
Labreche	Melvin	1877
Labreche	Millie	1918
Labreche	Minnie	
Labreche	Phil	1917
Labreche	Philis	1908
Labreche	Presley Phil	
Labreche	Theodore	1911
Labreche	Theophile	1883
Labuff	Theresa	1850
Labuff	Theressa	
Lacy	Albert	1889
Lacy	James	1883
Lacy	Jermia	1887
Lacy	John	1879
Lacy	Louis	1891
Lacy	Mand	1881
Lacy	Minnie	1885
Lacy	Sophia	1858
Lacy	William	1877
Lahr	Bessie	1880
Lahr	Bryan	1904
Lahr	Earl Henry	1913
Lahr	Elizabeth	1914
Lahr	Eloise	1906
Lahr	Henry	1881
Lahr	Henry J.	
Lahr	Henry Jr.	1908
Lahr	James	1909
Lahr	Lorena Wilma	1915
Lahr	Maud	1908
Lahr	Mrs H. J.	
Lahr	Muriel	1919
Lahr	Peter	
Lahr	Peter	
Lahr	Peter	1916
Lahr	Peter	1881
Lahr	Wilma	1915
Lame Bear	Carroll	1896
Lame Bear	Cecile	1899
Lame Bear	James	1897
Lame Bear	Mary	1876
Lame Bear	Thomas	1894
Lame Bear	Thomas	
Lamont	Joseph	1887
Lamott	Jeannie	1886
Lamott	Joseph	1917
Lamott	Minnie	
Lamott	Minnie	
Lamott	Minnie	1882
Lamott	Minnie	1882
Lana	Cosa Maria	1880
Lana	Margarette	1874
Lana	Pete	
Langley	Josephine	1875
Lapage	Annie	
Lapage	Phoebe	1892
Lapage	Theresa	
Larb	Bessie	1884
Larb	Henry	1884
Larb	Mark	
Larb	Mark	1840
Larb	Mark	1882
Larrabee	Eliza	1882
Last Calf	Charlie	1881
Last Calf	Lad	1870
Last Calf	Pete	1882
Last Coyote	Mary	1894
Last Coyote	Minnie	
Last Kills	Mary	
Last Star	Alice	1918
Last Star	Annie	1912
Last Star	Ellen	
Last Star	Florence Gold	1916
Last Star	Frances	1919
Last Star	Helen	
Last Star	John	1906
Last Star	Katie	1897
Last Star	Mable	
Last Star	Mark	1913
Last Star	May L. B.	1916
Last Star	Mike	1913
Last Star	Mrs.	
Last Star	Philip	1889
Last Star	Rose Old Man Chief	
Last Star	Susan	
Last Star	Theodore	
Last Star	Thomas	1901
Last Star	Tony	1893
Last Star	Woodrow Wilson	
Laurence	Betsy	
Laurence	John	
Laurence	John Baptist	1880
Laurence	John Baptiste	1914
Laurion	Ida	1875
Laurion	Josephine	1852
Laurion	Minnie	1884
Laurion	Octavia	1869
Lauzon	Peter	1881
Lavarro	Casuse	1909
Lavarro	Joseph	1876
Lavarro	Mary Kossuth	1914
Lawler	Mary J.	1916
Lazy Boy	Anna	1911
Lazy Boy	Annie	1890
Lazy Boy	Mack	
Lazy Boy	Samuel	1893
Lazy Boy	Thomas	1878
Lazy Man	John	1893
Le Buff	Alex	1916
Le Page	Phoebe	
Lean Back	Joseph	1869
Leaning Woman	Bill	1881
Leaning Woman	Frank	1877
Leaning Woman	Henry	18
Lebreche	Charles	
Lebreche	Charles D.	
Lebreche	Charlie	1866
Lebreche	David	1873
Lebreche	Elemor	1880
Lebreche	Jacques	1909
Lebreche	James R.	1905
Lebreche	Jessie	1884
Lebreche	Julia	1871
Lebreche	Madar	1877
Lebreche	Mary	1875
Lebreche	Millie	
Lebreche	Millie	
Lebreche	Millie	1881
Lebreche	Millie	1849
Lebreche	Minnie	1870
Lebreche	Philip	1886
Lee	Dick	1888
Lee	Philip A.	1922
Leiphart	Josephine	1876
Lemmon	Lee	96
Lemon	Emma	1894
Lemon	Jessie	1887
Lemon	John	1888
Lemon	Louisa	1892
Lemon	Mary	1869
Lemon	Rosa	1890
Lenoir	Adeline	1911
Lenoir	Clara	
Lenoir	Clara R.	1881
Lenoir	Joseph V.	1908
Lenoir	Julia May	1909
Lenoir	Louis	
Lenoir	Louis D.	1913
Lenoir	Louise S.	1906
Lenoir	Richard Oswald	1915
Lenoir	Victor Alphonse	1916
Leon	Frank	1844
Leon	Joe	1886
Lewis	Antoine	1884
Lewis	Betsey	1897
Lewis	Edward A.	1836
Lewis	Ellen	1862
Lewis	Frank	1920
Lewis	George	1894
Lewis	Joseph	1910
Lewis	Joseph N.	1901
Lewis	Josephine	1893
Lewis	Maggie	1883
Lewis	Margaret	
Lewis	Margarete	
Lewis	Margerate	
Lewis	Marguerete	1868
Lewis	Mary	1896
Lewis	Mollie	1872
Lewis	Mollie Mary	
Lewis	Mrs. Ed	1845
Lewis	Peter	1893
Lewis	Sarah	1894
Lewis	William	
Lewis	William	
Lewis	William	
Lewis	William	
Lewis	William	
Lewis	William	
Lewis	William	1906
Lewis	William	1854
Limebock	Joseph	1880
Lindell	Florence	1899
Lindell	John	1903
Lindell	Rosada	1878
Lippencott	John	1894
Lippencott	Mary	1892
Lippencott	Mary	1866
Listens To	Ellen	1882
Litel	Matt	
Little Plume	Albert	
Little Bear	Johnnie	1889
Little Bear	Joseph	1885
Little Bear	Susie	1867
Little Bear	Tom	1866
Little Blaze	Cecile	1919
Little Blaze	John	1919
Little Blaze	Rose	1922
Little Bull	Jack	
Little Bull	James	1892
Little Bull	John	1897
Little Bull	Josephine	
Little Bull	Thomas	1877
Little Dog	Alice	1909
Little Dog	Annie	1903
Little Dog	Belle	1888
Little Dog	Harrison	1880
Little Dog	Henry	1899
Little Dog	Irene	
Little Dog	Jack	1907
Little Dog	Jane	1907
Little Dog	Jane	1911
Little Dog	Jane	1910
Little Dog	Jeanette	1906
Little Dog	Jennie	1876
Little Dog	Jim	1917
Little Dog	Jim	1914
Little Dog	John	1906
Little Dog	Maggie	1896
Little Dog	Mary	1916
Little Dog	Mary	1896
Little Dog	Max	1879
Little Dog	Mike	1865
Little Dog	Richard	1901
Little Dog	Rosa	1912
Little Dog	Samuel	1878
Little Dog	Thomas	1918
Little Glittering	Mary	1878
Little Light	Alfreda	1919
Little Light	Arthur	1917
Little Light	Della Marie	1913
Little Owl	Annie	1902
Little Owl	Charles	1906
Little Owl	George	1898
Little Owl	Jennie	1882
Little Owl	Louise	1905
Little Owl	Lucy	1911
Little Owl	Maggie	1884
Little Owl	Mary	1917
Little Owl	Mary	1919
Little Owl	Mary	
Little Owl	Mary	
Little Owl	Mary	
Little Owl	Mary	1897
Little Plume	Albert	
Little Plume	Annie	
Little Plume	Annie	1910
Little Plume	Annie	
Little Plume	Annie	
Little Plume	Annie	
Little Plume	Annie	
Little Plume	Annie	1892
Little Plume	Bertha	1890
Little Plume	Charles	1910
Little Plume	Charles Patrick	1910
Little Plume	Cora	1878
Little Plume	Fred	1883
Little Plume	George	1901
Little Plume	George	1902
Little Plume	Gretchen	1900
Little Plume	Irvin	
Little Plume	Irvine	1878
Little Plume	James	
Little Plume	James	
Little Plume	James	
Little Plume	James	1884
Little Plume	James	1884
Little Plume	Jane	1880
Little Plume	John	
Little Plume	John	1919
Little Plume	John	1917
Little Plume	John	1917
Little Plume	John	1899
Little Plume	Joseph	1902
Little Plume	Joseph	1911
Little Plume	Joseph	1896
Little Plume	Josephine	1894
Little Plume	Louis	1889
Little Plume	Maggie	1896
Little Plume	Mary	
Little Plume	Mary	
Little Plume	Mary	1912
Little Plume	Mary	
Little Plume	Mary	1890
Little Plume	Mary	1897
Little Plume	Mary Ann	1890
Little Plume	Peter	1895
Little Plume	Thomas	1907
Little Skunk	Cecil	1894
Little Skunk	Cecile	1893
Little Skunk	Cecilia	
Little Skunk	Jane	1891
Little Skunk	Maggie	1890
Little Skunk	Mary	1847
Little Skunk	Mary Cadotte Grant	
Little Skunk	Peter Grant	1887
Little Skunk	Richard Grant	1876
Little Young Man	James	1918
Little Young Man	Mary	1914
Little Young Man	Peter	1917
Livermore	Alma	
Livermore	Clara	1891
Livermore	Edward	1910
Livermore	Emery Alexander	1913
Livermore	Joe	
Livermore	John	1884
Livermore	Joseph	1862
Livermore	Josephine	1861
Livermore	Julia	
Livermore	Julia	
Livermore	Julia	1908
Livermore	Julia	1887
Livermore	Lillian	1913
Livermore	Lillie	
Livermore	Lilly	1894
Livermore	Louise	
Livermore	Minnie	1882
Livermore	Octavia	1867
Livermore	Peter	
Livermore	Peter	
Livermore	Peter	
Livermore	Peter	
Livermore	Peter	
Livermore	Peter	1909
Livermore	Peter	1909
Livermore	Peter	1910
Lodge Pole	Louise	
Lodge Pole	Peter	
Lodge Pole	Raymond	1911
Lone Chief	Dan	1986
Lone Chief	Ellen	1875
Lone Chief	Grace	1895
Lone Cut	Charlie	1879
Lone Eater	Alice	1879
Lone Eater	Ella	1885
Lone Eater	George	
Lone Eater	George	
Lone Eater	George	1906
Lone Eater	George	1906
Lone Eater	George	1908
Lone Eater	George	1877
Lone Eater	George	1878
Lone Eater	Joseph	1906
Lone Eater	Maggie	1887
Lone Eater	Sallie	1906
Lone Eater	Sophia	1908
Lone Hit	Mary	1890
Lone Medicine Pipe	Cecil	1887
Long Fisher	Maggie	1887
Long Time Rock	Agnes	1911
Long Time Rock	Anna	
Long Time Rock	Annie	1873
Long Time Rock	George	1914
Long Time Rock	John	1907
Long Time Rock	William	1904
Long Time Sleeping	George	1919
Long Time Sleeping	James	1919
Long Time Sleeping	Jim	
Long Time Sleeping	John	1896
Long Time Sleeping	Joseph	1892
Long Time Sleeping	Maggie	1895
Long Time Sleeping	Rose	1901
Long Time Sleeping	Walter	1918
Long Time Star	Freddie	1889
Long Time Star	Johnny	1884
Long Time Star	Joseph	1886
Long Time Star	Mary	1841
Long Time Star	Samuel	1882
Looking For Smoke	Irene	1918
Looking For Smoke	Isadore	
Looking For Smoke	Isadore	1896
Looking For Smoke	John	1917
Looking For Smoke	Louis	1893
Loomis	Ella	
Loomis	George	1912
Loring	Everett	1917
Loring	Horace Joseph	1914
Loring	John	
Loring	William	1919
Lorstensen	Anna Marie	1920
Lorstensen	Mr.	
Lots Of Men	Sarah	1885
Louis	Louise	1889
Louis	Marguerete	
Louis	William	
Lourion	Octava	1872
Lucero	Dick	
Lucero	Eunice	1915
Lucero	Gladys	1913
Lucero	Helen	
Lucero	Jennie	
Lucero	Marita	1911
Lucero	Philip	
Lucero	Philip	
Lucero	Richard	
Lucero	Richard	1878
Lucero	Rosa	1903
Lucero	Rose Ada	1903
Lucier	Louise	1853
Lucier	Susette	1909
Lucier	Suzette	
Lucier	Thousan	
Lucier	Thousan 1	1909
Lucier	Thousan 2	1909
Lukin	Albert	1870
Lukin	Albert Peter	1915
Lukin	Alphinsine	1910
Lukin	Bernedetta	1918
Lukin	Dora	1877
Lukin	Dorthia Dora	1916
Lukin	Gertrude Mary	1913
Lukin	Hildegarde	
Lukin	John	1879
Lukin	Mary	1847
Lukin	Mary R.	1909
Lukin	Mary Rutledge	
Lukin	Peter	
Lukin	Peter	1881
Lukin	Peter H.	1867
Lukin	Peter Hector	1867
Lukin	Victoria	1877
Lukin	Victoria L	
Lukin	Victoria L.	
Lump Mouth	Frank	1876
Lump Mouth	Oliver	1874
Lwbreche	Jacques	
Lyttle	Katie	1879
Lyttle	Mathew	1872
Ma Ka	Andrew	1883
Macaw	Andrew	1882
Macaw	Francis	1877
Mack	Joseph	1888
Mackiskine	Bridget	1880
Mad Man	Alice	1906
Mad Man	Elizabeth	1917
Mad Man	Frank	1908
Mad Man	George	1918
Mad Man	Jeannette	1913
Mad Man	Josephine	
Mad Man	Josephine	
Mad Man	Josephine	
Mad Man	Josephine	
Mad Man	Josephine	1886
Mad Man	Josephine	1886
Mad Man	Mike	1904
Mad Man	Stephen	1885
Mad Man	Stephen Patrick	1910
Mad Man	Steve	
Mad Man	Steven	
Mad Plume	Agnes	1891
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	
Mad Plume	Albert	1867
Mad Plume	Albert	1873
Mad Plume	Annie	1914
Mad Plume	Benedict	1905
Mad Plume	Charles	1891
Mad Plume	Clara	1912
Mad Plume	Eddie	1877
Mad Plume	Ella	1906
Mad Plume	Elmer	1871
Mad Plume	Etta	1910
Mad Plume	Frank	1915
Mad Plume	George	1912
Mad Plume	George	1893
Mad Plume	George	1892
Mad Plume	Jack	1898
Mad Plume	Jack	1910
Mad Plume	Jack	1907
Mad Plume	John	1895
Mad Plume	John	1896
Mad Plume	John	1884
Mad Plume	Joseph	
Mad Plume	Josephine	1919
Mad Plume	Julia	1915
Mad Plume	Julia	1889
Mad Plume	Kills At Night	1857
Mad Plume	Lizzie	
Mad Plume	Louise	1913
Mad Plume	Lucy	1908
Mad Plume	Maggie	1896
Mad Plume	Mary	1901
Mad Plume	Mary	
Mad Plume	Mike	1894
Mad Plume	Mike	
Mad Plume	Minnie	1885
Mad Plume	Paul	
Mad Plume	Philip	1908
Mad Plume	Raymond	1919
Mad Plume	Richard	
Mad Plume	Richard	1910
Mad Plume	Richard	
Mad Plume	Richard	1910
Mad Plume	Richard	1881
Mad Plume	Richard	1884
Mad Plume	Sarah	1918
Mad Plume	Susan	
Mad Plume	Susan	
Mad Plume	Susan	
Mad Plume	Susan	
Mad Plume	Susan	1872
Mad Plume	Susan	1878
Mad Plume	Susie	
Mad Plume	Susy	1911
Mad Plume	Victor	1918
Mad Plume	Victoria	1915
Mad Wolf	Charles	1878
Mad Wolf	Mark	1888
Madman	Josephine	
Maganix	Augustine	1868
Magee	Adelma Emma	1916
Magee	Annie	1853
Magee	Bernadino	1919
Magee	Dewey	1894
Magee	Eleanor May	1919
Magee	Emma	
Magee	George	1892
Magee	George Burnside	1917
Magee	George Francis	1916
Magee	Henry	1918
Magee	Joseph	1886
Magee	Julia	
Magee	Julia	1890
Magee	Julia	
Magee	Julia	1913
Magee	Julia	1869
Magee	Julia Emily	1913
Magee	Julia Grant	1890
Magee	Mary	
Magee	Mary	
Magee	Mary	1909
Magee	Mary	1888
Magee	Merle	
Magee	Mrs Millie P.	
Magee	Thomas	
Magee	Thomas	
Magee	Thomas	1889
Magee	Thomas	1890
Magee	Thomas B.	1863
Magee	Thomas Nathanial	1909
Magee	Thomas Wilbur	1919
Magee	Walter	
Magee	Walter	
Magee	Walter	1895
Magee	Walter	1894
Magee	Walter G.	
Maginnio	Augustine	1867
Magnum	Susan	1856
Main	Alice	1891
Main	Henry	1879
Main	Henry W.	1907
Main	Henry Wellington	
Main	Isabel	
Main	Isabele	
Main	Lizzie	1912
Main	Mary	1916
Main	Oren Sherwood	
Main	Orrin S.	1854
Main	William	1881
Maine	Isabelle	
Maine	Lucy	1878
Makes Cold Weather	Joe	1893
Makes Cold Weather	John	1900
Makes Cold Weather	Mary	1896
Makes Cold Weather	Susie	1893
Makes Two Guns	Florence	1876
Makes Two Guns	Joseph	1896
Making Signs	Jim	1886
Malette	Assiny	
Malette	Mary	
Malgum	George	
Mallete	Assiny	
Mallete	Mary	1909
Man Top Not	Arthur	1882
Man Top Not	Jack	1884
Man Top Not	Kittie	1889
Man Top Not	Mary	1888
Mandan Woman	Martha	
Many Fingers	Willie	1886
Many Guns	Annie	1918
Many Guns	Edgar	1875
Many Guns	George	1892
Many Guns	Joe	1892
Many Guns	Josephine	1882
Many Guns	Margaret	1879
Many Guns	Mary	1890
Many Guns	Sam	1860
Many Guns	Sarah	1885
Many Guns	Sarah	1861
Many Guns	Susie	
Many Guns	Tom	1895
Many Hides	Child	
Many Hides	George	1916
Many Hides	James	1911
Many Hides	Maggie	1882
Many Hides	Mary	1902
Many Hides	Mollie Cecile	1903
Many Hides	Paul	1915
Many Hides	Paul	1915
Many Hides	Peter	1909
Many Hides	Peter	1909
Many Hides	Philip	1899
Many Hides	Robert	
Many Hides	Robert	
Many Hides	Robert	1874
Many Hides	Robert	1875
Many Hides	Susan Cecile	1918
Many Kills	Joe	1880
Many Kills	Marie	1882
Many Tail Feathers	Albert	1910
Many Tail Feathers	Alice	1891
Many Tail Feathers	Aloysies	1912
Many Tail Feathers	Bertha	1909
Many Tail Feathers	David	1907
Many Tail Feathers	James	
Many Tail Feathers	James	
Many Tail Feathers	James	
Many Tail Feathers	James	
Many Tail Feathers	James	1877
Many Tail Feathers	James	1877
Many Tail Feathers	Jennie	1916
Many Tail Feathers	Jenny	1889
Many Tail Feathers	John	1905
Many Tail Feathers	Josephine	
Many Tail Feathers	Julia	1899
Many Tail Feathers	Julia	1902
Many Tail Feathers	Lucy	1883
Many Tail Feathers	Mary	
Many Tail Feathers	Mary	1893
Many Tail Feathers	Mary	1909
Many Tail Feathers	Mary	1888
Many Tail Feathers	Mary	1896
Many Tail Feathers	Mary Ann	1894
Many Tail Feathers	Mole	1893
Many Tail Feathers	Tom	1910
Many Tail Feathers	Tom	1910
Many Tail Feathers	William	1907
Many White Horses	Cecile	1900
Many White Horses	Charles	1880
Many White Horses	Ganette	1865
Many White Horses	George	1893
Many White Horses	Jim	1888
Many White Horses	Joseph	1900
Many White Horses	Joseph	1889
Many White Horses	Maggie	1917
Many White Horses	Maggie	1919
Many White Horses	Maggie	
Many White Horses	Mary	1896
Many White Horses	Paul	1893
Many White Horses	Thomas	1882
Many White Horses	Young	1874
Marceau	Agnes	1917
Marceau	Aleck	
Marceau	Alex	
Marceau	Alex	
Marceau	Alex	
Marceau	Alex	
Marceau	Alex	
Marceau	Alex	
Marceau	Alex	
Marceau	Alex	1864
Marceau	Aloysius	1914
Marceau	Andrew	1911
Marceau	Annie	1897
Marceau	Charles	
Marceau	Charles 1	1876
Marceau	Charles 2	1908
Marceau	Emma	1916
Marceau	Emma S. R.	1916
Marceau	Francisco	1910
Marceau	Frank	1874
Marceau	George	1910
Marceau	Hal	1914
Marceau	Henry	1872
Marceau	Jennie	1888
Marceau	Joseph	1918
Marceau	Josephine	1888
Marceau	Josephine	
Marceau	Louis	1866
Marceau	Louise	
Marceau	Maggie	1910
Marceau	Maggie Rose	1881
Marceau	Margaret	
Marceau	Margaret	
Marceau	Margaret	1915
Marceau	Patrick	
Marceau	Peter	1873
Marceau	Phillip	
Marceau	Rosa	1916
Marceau	Theresa	1873
Marceau	Thomas	1918
Marceau.	Peter	
Marcereau	Catherine	1909
Marcereau	Charles	1908
Marcereau	Charley	
Marcereau	Maggie	
Marcereau	Maggie	
Marcero	Alex	
Marcero	Alex Jr.	
Marcero	Felix	1908
Marcero	Joe	1891
Marcero	Louis	
Marcero	Rosa	1879
Marcero	Theresa	
Marcette	Louise	
Marcia	Charles	
Marcia	Henry	1886
Marrow Bones	Fannie	1885
Marrow Bones	Fanny	1910
Marrow Bones	Felix	
Marrow Bones	Felix	
Marrow Bones	Felix	
Marrow Bones	Felix	1898
Marrow Bones	Felix	
Marrow Bones	Felix	
Marrow Bones	Felix	1877
Marrow Bones	Felix	1887
Marrow Bones	John	1900
Marrow Bones	Kate	
Marrow Bones	Lucy	1907
Marrow Bones	Mary	1876
Marrow Bones	Willie	1897
Marsero	Alex	1888
Marsero	Alex Sr.	
Marsero	Alexander	
Marsero	Alexander	1888
Marsero	Alexander	
Marsero	Alexander	
Marsero	Alexander	1837
Marsero	Alexander	1864
Marsero	Frank	1875
Marsero	Fransis	1877
Marsero	Jennie	1873
Marsero	Josephine	1887
Marsero	Louis	1867
Marsero	Louisa	1892
Marsero	Peter	1877
Marsero	Rosa	1849
Marsero	Theresa	1871
Marsero	Theresa Black Boy	
Marsette	Louise	
Marshall	Charles	1909
Marshall	Elizabeth	1909
Marshall	Susan	1907
Martin	Ada	1904
Martin	Alice	
Martin	Alice	1876
Martin	Alice	1877
Martin	Charles	
Martin	Charlie	1871
Martin	Floyd E.	1917
Martin	Leslie	1901
Martin	Maud	
Martin	Maude	1876
Martin	Nina	1904
Martin	Phena	
Martin	Rena	
Martin	Rena	
Martin	Rena	1896
Martin	Ross	1894
Martin	Virgil	1907
Masterman	Alma	1906
Masterman	Edith	1887
Masterman	Ira	1920
Masterman	Violet	1910
Matt	Adeline	
Matt	Adline	1867
Matt	Albert	1896
Matt	Alice	1894
Matt	Angelse	
Matt	Annie	1883
Matt	Antonine	1877
Matt	Baptiste	1850
Matt	David	1888
Matt	Delphina	1917
Matt	Edmund	1911
Matt	Edmund	1911
Matt	Edward	1911
Matt	Elmer	1915
Matt	Esther	1903
Matt	Evelyn	1915
Matt	Evenni	1881
Matt	File	1883
Matt	Francis	1896
Matt	George	1909
Matt	Gladys	1917
Matt	Jule	1873
Matt	Lena	1895
Matt	Louie	
Matt	Louis	
Matt	Louis	
Matt	Louis	
Matt	Louis	
Matt	Louis	
Matt	Louis	
Matt	Louis	1909
Matt	Louis	1860
Matt	Louise	
Matt	Louise	
Matt	Louise	
Matt	Louise	
Matt	Louise	1906
Matt	Louise C.	1880
Matt	Mary	
Matt	Mary	
Matt	Mary	
Matt	Mary	
Matt	Mary	
Matt	Mary	1894
Matt	Mary	1851
Matt	Michael	1882
Matt	Michel	1881
Matt	Robert	1913
Matt	Theodore	1899
Matt	Theresa	1909
Matt	William	1885
Mc Cartney	Milo	
Mc Leod	Alexander	1921
Mc Mullin	Ellen	1905
Mc Mullin	George	
Mc Mullin	Joseph	1878
McAnulty	Ruth	1915
McCoy	Fransis	1877
McDougal	John	
McGovern	Alice	
McGovern	Dan	
McGovern	Eliza	1907
McGovern	Georgiana	1899
McGovern	John	1895
McGovern	Maggie	1894
McGovern	Mary Catherine	1919
McGovern	Sophia	1870
McGovern	Violet Evelyn	1917
McGovern	Walter	1906
McGowan	Ezra	1900
McGowan	Jeanette	
McGowan	Jeannette	
McIntee	William	1866
McIntire	William	1913
McKay	Butch	1917
McKay	Howard	1922
McKay	Isabelle	
McKay	Joe	
McKay	John	1918
McKay	Josie	1914
McKay	Margaret	1913
McKay	Thomas	1917
McKay	Victoria	1860
McKay	Viola Welch	1883
McKee	Jane	
McKelvey	Alfreda Loraine	1908
McKelvey	Cecelia	
McKelvey	Cecilia	
McKelvey	Charles Fremont	1919
McKelvey	Dora	1886
McKelvey	Elizabeth	1906
McKelvey	Flora B.	1915
McKelvey	Frank	1889
McKelvey	George	
McKelvey	Helen	1913
McKelvey	John	
McKelvey	Joy Aleximo	1918
McKelvey	Mary Houseman	
McKilvey	C. F.	
McKilvey	C.F.	
McKilvey	Consuello	1913
McKilvey	Flora B.	1895
McKilvey	George	1892
McKilvey	John	
McKilvey	Mary Houseman	
McKilvey	Urbanna Jeannitte	1911
McKilvy	Cecile	1866
McKilvy	Ike	1888
McKilvy	Joe	1892
McKilvy	John	1886
McKilvy	Josephine	1894
McKilvy	Mary	1890
McKnight	Annie	1871
McKnight	Eliza	1875
McKnight	Ella	1902
McKnight	Henry	1898
McKnight	Irene	1889
McKnight	Joe	
McKnight	Joseph	
McKnight	Joseph	
McKnight	Joseph	
McKnight	Joseph	1892
McKnight	Joseph	1874
McKnight	Lucy	1877
McLeod	Alexander	1921
McMullan	Nellie	1883
McMullen	Joseph Jr.	1919
McNabb	Roy	
McVay	Mary	
McVay	Susan	1885
McVay	William	
Mead	James	
Meade	Anna	1906
Meade	Anna Mary	1910
Meade	Annie Mary	1910
Meade	Isabel Agnes	1908
Meade	Mary	
Meade	Mary Dawson	1883
Meade	Mary L.	1907
Meade	Mary Lorena	1907
Meade	Mary Lorene Dawson	1907
Meade	Mary Lovina	1907
Meade	Mary Theresa	1911
Meade	W.H.	
Meade	William H.	1876
Meade	William H. Jr.	1914
Meade	William Henry	1914
Medicinal Weasel	Susan	
Medicine Boss Ribs	Emma	1884
Medicine Boss Ribs	Julia	1896
Medicine Boss Ribs	Maggie	
Medicine Bull	Cecile	894
Medicine Bull	Mary	1919
Medicine Bull	Thomas	
Medicine Bull	Tom	1896
Medicine Owl	Joseph	1888
Medicine Stab	Sam	1873
Medicine Weasel	Susan	1892
Medicine Weasel	Theresa	1902
Medicine Wolf	Charles	1887
Medicine Wolf	Martha	1883
Medicine Wolf	Samuel	1885
Medicine Wolf	Susie	1893
Merchant	Caroline	1884
Merchant	Cecile	1914
Merchant	Daniel	
Merchant	Edith	1912
Merchant	Emma	1901
Merchant	Esther	1910
Merchant	Ethel	1900
Merchant	Fabian	1900
Merchant	Frank	1901
Merchant	Fred	1908
Merchant	Henry	1874
Merchant	John	1875
Merchant	Lucya Cordine	1908
Merchant	Mabel	1905
Merchant	Mary	1907
Mercier	Baptiste	
Mercier	Baptiste Rondin	
Mercier	Charles	1909
Mercier	Charles Rondin	
Mercier	Elisa	1909
Mercier	Eliza	1909
Mercier	Isabel	
Mercier	Isabelle	
Mercier	Mary Rondin	
Mercier	Phillip	1898
Mercier	Samuel Rondin	1887
Mercier	Victoria	
Mercier	Victoria Rondin	1909
Mercure	Susan	1864
Mestas	John	
Middle Bull	John	1871
Middle Calf	Agne	
Middle Calf	Agnes	1873
Middle Calf	Annie	
Middle Calf	Cecile	1912
Middle Calf	Charles	1887
Middle Calf	Fannie	1907
Middle Calf	James	1902
Middle Calf	John	1851
Middle Calf	Margaret	1918
Middle Calf	Mary	
Middle Calf	Mary	
Middle Calf	Mary	1898
Middle Calf	Mary	1890
Middle Calf	Mollie	
Middle Calf	Mollie	1881
Middle Calf	Mollie	1878
Middle Calf	Ruth	1880
Middle Calf	Sam	1870
Middle Calf	Theresa	1911
Middle Calf	William	1907
Middle Rider	Annie	1875
Middle Rider	Fred	1881
Middle Rider	John	1895
Middle Rider	Joseph	1908
Middle Rider	Levi	1887
Middle Rider	Mary	1893
Middle Rider	Mrs. Annie	
Middle Rider	Robert	1909
Middle Rider	Rosa	1907
Middle Rider	Rose	1907
Middle Rider	Sam	1916
Middle Rider	Susie	1916
Miller	Emily	1890
Miller	Emily	1890
Miller	Emma	1865
Miller	Emma Upham Heavy Runner	
Miller	Jack	
Miller	Jack	
Miller	Jack	
Miller	Jack	1845
Miller	Jack	1864
Miller	Jacob	
Miller	Josephine	1893
Miller	Julia	1857
Miller	Margaret	1917
Miller	Mary	1870
Miller	Rosa	1881
Minski	Mary Jane	
Mittens	Annie	1893
Mittens	Daniel	1919
Mittens	George	1907
Mittens	James	
Mittens	Jessie	
Mittens	John	1896
Mittens	Mary	1908
Mittens	Peter	1899
Mittens	Richard	1895
Mittens	Robert	1901
Mixing Tobacco	George	1872
Mixing Tobacco	Hamlin	1887
Mixing Tobacco	Louis	1874
Mixing Tobacco	William	1883
Mocaw	Frank	1878
Moccasin	John	1873
Mom Berg	Louis	
Momberg	Bessie	1896
Momberg	Hazel	1900
Momberg	Helen Anna	1918
Momberg	Louis	
Momberg	Maud	1896
Momberg	Ray	1899
Monette	John	
Monroe	Alice	1896
Monroe	Aloysis	1917
Monroe	Amelia	1889
Monroe	Andrew	1890
Monroe	Angus	1913
Monroe	Angus E.	1890
Monroe	Antoine	1914
Monroe	Antwine	1888
Monroe	Calvin John	1915
Monroe	Carrie	
Monroe	Carrie Barbara	1917
Monroe	Carrie H.	
Monroe	Cecile Virginia	1911
Monroe	Charles	1897
Monroe	Christine	1905
Monroe	Donald Bruce	1921
Monroe	Ellen	1908
Monroe	Emma	1916
Monroe	Floyd T. Or F.	1913
Monroe	Francios	1849
Monroe	Francios Mrs.	
Monroe	Francis	1876
Monroe	Francois Mrs.	1854
Monroe	Frank	
Monroe	Frank	
Monroe	Frank	
Monroe	Frank	
Monroe	Frank	
Monroe	Frank	
Monroe	Frank	
Monroe	Frank	1871
Monroe	Frank	1884
Monroe	Frank	1848
Monroe	Geraldine Olive	1922
Monroe	Gifford	1905
Monroe	Grinnell	1896
Monroe	Gus	1887
Monroe	Harvey John	1915
Monroe	Hattie	1900
Monroe	Hue	1879
Monroe	Hugh	
Monroe	Hugh	1909
Monroe	Hugh	1893
Monroe	Isabel	
Monroe	Jennie	1883
Monroe	Jesse	
Monroe	Jessie	
Monroe	Joe	1863
Monroe	Joe	1884
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	
Monroe	John	1910
Monroe	John	1827
Monroe	John B.	
Monroe	John Lindhe	1917
Monroe	Joseph	1884
Monroe	Joseph	1917
Monroe	Joseph	
Monroe	Joseph	
Monroe	Joseph	
Monroe	Joseph	1916
Monroe	Joseph	1850
Monroe	Joseph Grinnell	1916
Monroe	Joseph R.	1917
Monroe	Justin	1872
Monroe	Justina	1870
Monroe	Justine	
Monroe	Lewis	1882
Monroe	Liberty	1918
Monroe	Lillie	1890
Monroe	Lizzie	
Monroe	Lizzie Whitford	
Monroe	Louis	
Monroe	Louis	1907
Monroe	Louis	
Monroe	Louis	
Monroe	Louis	
Monroe	Louis	
Monroe	Louis	
Monroe	Louis	
Monroe	Louis L.	1910
Monroe	Louise	1872
Monroe	Lucille	1915
Monroe	Margaret	1916
Monroe	Mary	
Monroe	Mary	1907
Monroe	Mary	
Monroe	Mary	
Monroe	Mary	1887
Monroe	Mary	
Monroe	Mary	
Monroe	Mary	1910
Monroe	Mary	1910
Monroe	Mary	1910
Monroe	Mary	
Monroe	Mary K.O.T.S.	1855
Monroe	Mary V.	1885
Monroe	Mary Virginia	1887
Monroe	Mrs. William	1887
Monroe	Peter	1890
Monroe	Sarah	1891
Monroe	Sarah Ellen	1916
Monroe	Sophia	1872
Monroe	Susan	1839
Monroe	Victoria	
Monroe	Wanda Marie	1919
Monroe	Weason	1879
Monroe	William	1847
Morgan	Agnes	1895
Morgan	Albert	1893
Morgan	Alice	1895
Morgan	Alice	1891
Morgan	Annetta	
Morgan	Cecilia	1907
Morgan	Chester	1904
Morgan	Claude	1900
Morgan	Cleo Genevieve	1917
Morgan	David	
Morgan	Eliza	1888
Morgan	Elizabeth	1884
Morgan	Emily	1887
Morgan	Fannie	
Morgan	Fanny	1891
Morgan	George	1881
Morgan	George	1882
Morgan	Harry	1917
Morgan	Hildegarde	1915
Morgan	Irene	1905
Morgan	Jesse	1882
Morgan	John	
Morgan	John	
Morgan	John	
Morgan	John	
Morgan	John	1913
Morgan	John	1889
Morgan	John	
Morgan	John	
Morgan	John	
Morgan	John	
Morgan	John	1860
Morgan	John	
Morgan	John	1895
Morgan	John B.	
Morgan	John B.	
Morgan	John B.	1909
Morgan	John B.	1909
Morgan	Johnny	1868
Morgan	Joseph	1916
Morgan	Kate	1898
Morgan	Lizzie	1885
Morgan	Louis	1886
Morgan	Lucy	
Morgan	Lucy	
Morgan	Lucy	1874
Morgan	Maggie	1887
Morgan	Mary	
Morgan	Mary	
Morgan	Mary	1881
Morgan	Mary	1861
Morgan	Mary	1894
Morgan	Mary	1862
Morgan	Millie	
Morgan	Minnie	1889
Morgan	Nellie	1889
Morgan	Peter	1915
Morgan	Raphael	1853
Morgan	Raphael Jr.	1903
Morgan	Raymond	1902
Morgan	Robert	1896
Morgan	Rosa	
Morgan	Rosa	
Morgan	Rosa	1912
Morgan	Rosa	
Morgan	Sybil Naomi	1918
Morgan	Virginia	1898
Morgan	Wilbert	1891
Morgan	William	
Morgan	William	
Morgan	William	
Morgan	William	1900
Morgan	William	1902
Morgan	William	1863
Morning Eagle	George	
Morning Eagle	Louis	1892
Morning Gun	Annie	1893
Morning Gun	Briar	1895
Morning Gun	Cora	1883
Morning Gun	Dick	1914
Morning Gun	Dick	1917
Morning Gun	Emma	1893
Morning Gun	Henry	1906
Morning Gun	Isabelle	1919
Morning Gun	James	1901
Morning Gun	Johanna	
Morning Gun	John	1911
Morning Gun	Johnny	1886
Morning Gun	Joseph	1900
Morning Gun	Kate	1904
Morning Gun	Rosa	
Morning Gun	Samuel	1888
Morning Gun	Susie	1890
Morning Gun	Wesley	1882
Morning Plume	Child	
Morning Plume	Florence	
Morning Plume	Frances	1892
Morning Plume	Francis	
Morning Plume	James	1897
Morning Plume	James	1900
Morning Plume	John	1892
Morning Plume	Paul	1894
Morris	Gregory Allen	1919
Moseney	Charles	1886
Moseney	Margaret	
Moseney	Xavier	1910
Moseny	Maggie	1863
Mott	Evelyn	
Mott	Fred	1878
Mott	Joseph	
Mott	Melissa	
Mountain Chief	Annie	1895
Mountain Chief	Antoine	
Mountain Chief	Cecelia	1887
Mountain Chief	Cecile	1899
Mountain Chief	Charles A.	
Mountain Chief	Dick	1888
Mountain Chief	Garrett	
Mountain Chief	Henry	1916
Mountain Chief	James	1879
Mountain Chief	John	
Mountain Chief	John	
Mountain Chief	John	
Mountain Chief	John	
Mountain Chief	John	1900
Mountain Chief	John	1900
Mountain Chief	John	1916
Mountain Chief	John	1875
Mountain Chief	John	1879
Mountain Chief	Joseph	1881
Mountain Chief	Louise	1878
Mountain Chief	Minnie	
Mountain Chief	Tecla	
Mountain Chief	Theckla	
Mountain Chief	Thecla	1916
Mountain Chief	Thekla	
Mountain Chief	Walter	
Mountain Chief	Walter J.	1918
Mountain Child	Snake Off The Timber	1892
Mountain Lion	James	1891
Mountain Lion	Mary	1874
Mountain Lion	Minnie	1879
Mountain Lion	Peter	1879
Mouse Woman	Mary	1882
Moves Out	Louis	1860
Moves Out	Louise	
Moves Out	Philomene	1857
Mud Head	Harry	1894
Mud Head	Nora	
Mud Head	Tallow	1894
Mumberg	Julia	1872
Mumberg	L.J.	1897
Munro	Alfred	1891
Munro	Antoine	1878
Munro	Ben	1893
Munro	Campbell	1869
Munro	Frank	
Munro	Frank	
Munro	Frank	1918
Munro	Frank	1848
Munro	Frozen	1875
Munro	Henry	1896
Munro	Lewis	1882
Munro	Mary	1853
Munroe	Alice	1916
Munroe	Aloysis Joseph	1916
Munroe	Amelia	
Munroe	Angus	1913
Munroe	Antoine	1914
Munroe	Carol	1917
Munroe	Carrie	1869
Munroe	Donald	1891
Munroe	Henry	1896
Munroe	Hugh	
Munroe	Jesse	1894
Munroe	John	1896
Munroe	John Lindhe	1917
Munroe	Joseph	1897
Munroe	Josephine	1868
Munroe	Juanita	1918
Munroe	Louis	
Munroe	Louise	
Munroe	Mabel	1892
Munroe	Margaret	1909
Munroe	Maron	1898
Munroe	Montcalm	1901
Munroe	William	
Murphy	Albert	1890
Murphy	Albert Arthur	1915
Murphy	Alice	1911
Murphy	Augusta	
Murphy	Augusta R	1908
Murphy	Avelina Leona	1914
Murphy	Carma	
Murphy	Earl Wilmer	1917
Murphy	Edwin T.	1914
Murphy	Esther May	1915
Murphy	Eveline Carma	1914
Murphy	Florence	
Murphy	Frank	1888
Murphy	Hamlin	1884
Murphy	Harland	1888
Murphy	John	1890
Murphy	John Patrick	1918
Murphy	Josephine W.	1880
Murphy	Julia	1884
Murphy	L. G.	
Murphy	Leo	1908
Murphy	Louis	1874
Murphy	Lucille	1919
Murphy	Mary	1845
Murphy	Mary Elizabeth	1916
Murphy	Mary Ethel	1910
Murphy	Meloina	
Murphy	Melvina	
Murphy	Melvina White	
Murphy	Michael	1891
Murphy	Rose Anita	1912
Murphy	Rufus Taft	1909
Murphy	Sara	1917
Murphy	Theda June	1918
Murphy	Violet	
Murphy	Violet Joy	1919
Murphy	William	
Murphy	William D.	1884
Murphy	William M.	
Murphy	William S.	1883
Mutch	Celina Paul Matt	
Mutch	Ernest Leonard	1918
Mutch	Pearl Helen	1919
Muxnroe	Sidney	1918
Nelson	Leslie	
Nelson	Margaret Evelyn	1918
Nelson	Mary	
Nequette	Anna	1885
Nequette	Charles	
Nequette	Charles	1914
Nequette	Charles	
Nequette	Charles	
Nequette	Charles	
Nequette	Charles	
Nequette	Charles	1882
Nequette	Charles	1885
Nequette	Florence	1903
Nequette	George	1908
Nequette	Hazel	1906
Nequette	Joe	1901
Nequette	Joseph	
Nequette	Joseph	
Nequette	Joseph	
Nequette	Joseph	1909
Nequette	Joseph	1878
Nequette	Josephine	1885
Nequette	Katie	1911
Nequette	Louis	1880
Nequette	Margaret	1900
Nequette	Mary	
Nequette	Mrs. Charles	
Nequette	Robert	1913
Nequette	Sophia	
Ness	Gehard	
Ness	James Ralph	1919
New Breast	Alexander	
New Breast	John	1890
New Breast	Joseph	1905
New Crow	Billy	1823
New Crow	Johnny	1874
New Robe	Agnes	1914
New Robe	Fanny	1881
New Robe	George	1919
New Robe	Jack	1917
New Robe	Jeannette	1896
New Robe	Joe	1886
New Robe	John	1883
New Robe	Joseph	1914
New Robe	Kate	
New Robe	Louis	1899
New Robe	Louise	1870
New Robe	Maud	1914
Nichols	Cecile	1895
Niddle Rider	Fred	1907
Night Eagle	Annie	1892
Night Eagle	Mary	1922
Night Gun	Annie	
Night Gun	Annie	
Night Gun	Annie	1906
Night Gun	Annie	1894
Night Gun	Bert	1850
Night Gun	Bertha	1919
Night Gun	Charles	1887
Night Gun	Child	
Night Gun	Edward	1906
Night Gun	George	1899
Night Gun	Isabelle	1903
Night Gun	Jack	1907
Night Gun	Jack	1888
Night Gun	James	
Night Gun	Joe	1888
Night Gun	John	1868
Night Gun	Joseph	1915
Night Gun	Joseph	1898
Night Gun	Josephine	1890
Night Gun	Julia	1887
Night Gun	Louis	1900
Night Gun	Lucy	1900
Night Gun	Maggie	1911
Night Gun	Maggie	
Night Gun	Martha	1904
Night Gun	Mary	1887
Night Gun	Minnie	
Night Gun	Minnie	
Night Gun	Minnie	
Night Gun	Minnie	
Night Gun	Minnie	
Night Gun	Minnie	1897
Night Gun	Minnie	
Night Gun	Minnie	1884
Night Gun	Mrs. Wallace	1887
Night Gun	Perry	1921
Night Gun	Samuel	1886
Night Gun	Stella	1878
Night Gun	Susan	1892
Night Gun	Susie	1910
Night Gun	Wallace	1876
Night Shoot	George	1896
Night Shoot	Henry	1907
Night Shoot	Joseph	1889
Night Shoot	Josephine	1912
Night Shoot	Josephine	1901
Night Shoot	Josephine	1901
Night Shoot	Maggie	1898
Night Shoot	Mary	
Night Shoot	Mary	1918
Night Shoot	Mary	1910
Night Shoot	May	1918
No Bear	Henry	1868
No Bear	Jennie	
No Bear	Mary	1905
No Bear	Rosa	1898
No Bear	Simon	1910
No Bear	Thomas	
No Bear	Thomas	1895
No Bear	Thomas	1896
No Chief	Angeline	1910
No Chief	Ellen	1873
No Chief	Florine	1919
No Chief	Gertrude	1878
No Chief	Grace	1895
No Chief	Gracie	1896
No Chief	Harry	1873
No Chief	Harry Jr.	
No Chief	James	1986
No Chief	Jim	
No Chief	Jim	
No Chief	Jim	
No Chief	Jim	1870
No Chief	Jim	1895
No Chief	Jim	1871
No Chief	Mary	1895
No Chief	Phillip	1913
No Chief	Theresa	1904
No Coat	Anna	1886
No Coat	Annie	1909
No Coat	Cecile	1902
No Coat	Charles	1902
No Coat	Charles	
No Coat	Charles	1869
No Coat	James	1885
No Coat	John	1889
No Coat	Julia	1908
No Coat	Julia	1893
No Coat	Mary	1886
No Runner	Agnes	1905
No Runner	Aliminia	1911
No Runner	Cecile	1903
No Runner	George	1915
No Runner	George	1889
No Runner	John	1902
No Runner	John	1892
No Runner	Joseph	1913
No Runner	Mary	1877
No Runner	Susan	1878
No Runner	Tim	1873
Nomland	Kemper	
Norman	Adella	1901
Norman	Adolph	
Norman	Adolphas	1896
Norman	Alden Frank	1919
Norman	Alfred	1896
Norman	Frank	
Norman	Frank	1908
Norman	Frank	1854
Norman	Lena	1895
Norman	Lillian Mary Thelma	1913
Norman	Mary	
Norman	Miguel	1909
Norman	Philip	1907
Norman	Thelma M.T.	1913
Norman	William	1910
Norman	William	1901
Norris	Daisy	1898
Norris	Daniel	1893
Norris	Dorothy	
Norris	Henry	
Norris	Jesse Willard	1916
Norris	Mary	
Norris	Mary Daisy	
Norris	Rachel	
Norris	Rachel	
Norris	Rachel	
Norris	Rachel	1871
Norris	Rachel	1871
Norris	Rosa	1889
Not Quite Time	Jane	1889
Not Quite Time	Mary	1888
Ogden	Angeline	1880
Ogden	Michelle	
Ohays	Angus	1908
Ohays	Rosa	
Ohays	William	
Old Bear Chief	Joseph	1893
Old Bear Chief	Mollie	1895
Old Chief	Annie	1899
Old Chief	Cecile	1918
Old Chief	Cecile Cold Body	1906
Old Chief	Daniel	1893
Old Chief	Joe	1895
Old Chief	John	1885
Old Chief	John Jr.	1915
Old Chief	Josephine	1912
Old Chief	Mary	
Old Chief	Mary	
Old Chief	Mary	1915
Old Chief	Mary	
Old Chief	Paul	
Old Chief	Robert	1902
Old Chief	Rose	1917
Old Chief	Theresa	1905
Old Chief	Thomas	1919
Old Child	Isabelle	1887
Old Child	Johnny	1883
Old Child	Molly	1859
Old Coyote	Lucy	1891
Old Dhief	John	1911
Old Man Chief	Anna	1910
Old Man Chief	James	1893
Old Man Chief	John	1899
Old Man Chief	Katie	1895
Old Man Chief	Louis	1903
Old Man Chief	Louise	1907
Old Man Chief	Lucy	1875
Old Man Chief	Mary	1895
Old Man Chief	Paul	1896
Old Man Chief	Rosa	1873
Old Man Chief	Rose	1919
Old Man Chief	Thomas	1903
Old Person	Anthony	1900
Old Person	Charlotte	1913
Old Person	Clara	1915
Old Person	Edna	
Old Person	George	1905
Old Person	Grace	
Old Person	Gracie	1877
Old Person	Hattie	1893
Old Person	Henry	1888
Old Person	Jennie	1891
Old Person	John	1896
Old Person	Juniper	1878
Old Person	Levi	1906
Old Person	Mary	1911
Old Person	Mollie	1887
Old Person	Molly	
Old Rock	Frank	1919
Old Rock	George	1910
Old Rock	James	1919
Old Rock	John	1903
Old Rock	Josephine	1916
Old Rock	Louis	
Old Rock	Louis	1906
Old Rock	Maggie	
Old Rock	Nellie	1873
Old Rock	Paul	1895
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	
Old Rock	Peter	1878
Old Rock	Peter	1877
Old Rock	Rose	
Old Rock	Susie	1912
Old Rock	Walter	1914
Old Rock	William	1914
Old Rock	William	1900
Old Running Rabbit	Guy	1877
Old White Woman	Loise	1865
Old White Woman	Thomas	1871
Ollinger	Alice M.	
Ollinger	Earl J.	
Ollinger	Hattie H.	
Ollinger	Irvin	1916
Ollinger	James Oscar	1911
Ollinger	Joseph	
Ollinger	Joseph Cayton	1878
Ollinger	Mary	
Ollinger	Mary Cayton	
One Horn	James	1891
Orton	Florence	1918
Oscar	Mary	
Oscar	Peter	1871
Otto	Louis	1915
Owens	Ardis Fern	1916
Owens	Cardinal Bird	1918
Owens	Charles	
Owens	Georgiana	
Owl Child	Agnes	1918
Owl Child	Anna	1894
Owl Child	Charles	1891
Owl Child	Frank	1913
Owl Child	Frank	1885
Owl Child	Grace	1913
Owl Child	Isabel	1887
Owl Child	Isabelle	1912
Owl Child	Joe	
Owl Child	John	1883
Owl Child	Joseph	1890
Owl Child	Josephine	1919
Owl Child	Louie	1893
Owl Child	Louis	1892
Owl Child	Mary	
Owl Child	Mary	
Owl Child	Mary	
Owl Child	Mary	1864
Owl Child	Minnie	
Owl Child	Mollie	
Owl Child	Rose Hildegarde	1915
Owl Child	Susan	1881
Owl Child	William	
Owl Feathers	Dick	1880
Owl Feathers	John	1894
Owl Feathers	Mary	1890
Owl Feathers	Mary	1881
Owl Feathers	Nick	1881
Owl Top Feathers	Child	1902
Owl Top Feathers	Julia	1862
Owl Top Feathers	Lorrine	1899
Owl Top Feathers	Maud	1890
Pablo	Agnes	1893
Pablo	Christine	1894
Pablo	Daisy	
Pablo	Emma	1891
Pablo	Eva	1896
Pablo	Frank	
Pablo	George	1866
Pablo	Maggie	
Pablo	Marie	1895
Pablo	Mary	1874
Pablo	Sarah	1875
Pablo/Starr	Isabelle	
Paid Up	Jack	1886
Painted Wing	Baptiste	1881
Painted Wing	Carrie	1892
Painted Wing	John	1887
Painted Wing	Simon	1877
Painted Wing	Susan	1888
Painted Wings	John	1877
Paisley	Albert	1888
Paisley	Allen	1887
Paisley	Amos	1910
Paisley	Benoin George	1915
Paisley	Chauncey	1886
Paisley	Chauncy	
Paisley	Cricket	1892
Paisley	Edward	1906
Paisley	Ethel	1902
Paisley	Ferris	1917
Paisley	George	
Paisley	George	1884
Paisley	Ivey Mazie	1913
Paisley	John	1894
Paisley	Lottie C.	1908
Paisley	Lottie Carrie	1908
Paisley	Louise	
Paisley	Low	1861
Paisley	Marie	1901
Paisley	Mattie	
Paisley	Mattie Hassen	1892
Paisley	May Ester	1911
Paisley	Nellie	1881
Paisley	Roderick Jared	1918
Pambren	Annie	
Pambren	George	1908
Pambren	George	1893
Pambren	George N.	
Pambren	Isabell	
Pambren	Louis	
Pambron	James	1866
Pambrun	Annie	1866
Pambrun	Cecil	1891
Pambrun	Cecil	1883
Pambrun	David	1889
Pambrun	Edward	1886
Pambrun	Florence	1893
Pambrun	Isabele Burdeau	
Pambrun	Isabell	1916
Pambrun	James	
Pambrun	Joseph	1916
Pambrun	Louis	
Pambrun	Louis	
Pambrun	Louis	1906
Pambrun	Louis	1858
Pambrun	Mary	
Pambrun	Teresa	1851
Pambrun	Theresa	1904
Pambrun	Thomas	1891
Pappan	Mary	
Park	Eliza	1881
Park	Eliza 2	1881
Park	Eliza1	
Park	William	1909
Parker	Eleanor	
Parker	Florence Naomi	
Parker	Maggie	1882
Parker	Mary	1893
Parker	Matt	1891
Parker	Nellie	1883
Parker	Regina Mahalla	1913
Patterson	Frederick M.	1894
Patterson	Judith	1858
Patterson	Malcolm E.	
Patterson	Mary	1893
Paul	Albert	1880
Paul	Alfreda	1912
Paul	Celina	1915
Paul	Clarence	1914
Paul	Dorothy May	1914
Paul	Eddie	1886
Paul	Edna Alice	1915
Paul	Edward	
Paul	Elgier	
Paul	Francis	1908
Paul	George	1909
Paul	Helen	1880
Paul	Isabel	
Paul	Isabel Burdeau Double Runner	1909
Paul	Joseph Earl	1917
Paul	Josephine	
Paul	Lawrence Edward	1914
Paul	Lena	1911
Paul	Leonard	
Paul	Louisa	1857
Paul	Louise	
Paul	Mary	1878
Paul	Mary Ether Vine	1912
Paul	Mildred Blanche	1917
Paul	Nellie	1907
Paul	Norine	1916
Paul	Oliver	
Paul	Oliver	
Paul	Oliver	1908
Paul	Oliver	1890
Paul	Pauline Dorothy	1939
Paul	Philip	1883
Paul	Roger	1918
Paul	Rosa	1888
Paul	Ruby	1905
Paul	Selena	1895
Paul	Soloman	
Paul	Solomon	1878
Paul	Sopha	1890
Paul	Stanley	1913
Paul	Susie	
Paul	Theresa La Boeuff	1892
Paul	Vernette	1907
Paul	William	1892
Paul	Willie	
Pearl Woman	Kate	
Pelite	Cary	1883
Pelite	Cecile	1874
Pelite	Chester	1885
Pelite	Frank	1882
Pelite	John	1871
Pelite	Louise	1877
Pemister	James	1874
Pendegrass	Charles Henry	1912
Pendegrass	Julia	1891
Pendegrass	Martin	1891
Pendegrass	Millie	1895
Pendergrass	Charles	1912
Pendergrass	Emily	1892
Pendergrass	George	1895
Pendergrass	Henry P.	1909
Pendergrass	Julia	
Pendergrass	Lenore	1898
Pendergrass	Martin	1901
Pendergrass	Mary	1909
Pendergrass	Theophite	1896
Pepion	Alfred Lewis	1916
Pepion	Aloysius	1892
Pepion	Annie	1907
Pepion	Cecil	
Pepion	Cecile	1905
Pepion	Cecilia	1875
Pepion	Celestel	1913
Pepion	Chester	
Pepion	Chester	
Pepion	Chester	
Pepion	Chester	
Pepion	Chester	
Pepion	Chester	1912
Pepion	Chester	1882
Pepion	Cynthia	1905
Pepion	Daniel Webster	1919
Pepion	Frank	1872
Pepion	Frank X.	1880
Pepion	Geneva	1902
Pepion	George	1909
Pepion	Gladys	1911
Pepion	Grace	1910
Pepion	Jeanette	1902
Pepion	Jess	1897
Pepion	Jesse	1878
Pepion	Jessie	1897
Pepion	John	1872
Pepion	Julia	
Pepion	Julia Mad Plume Four Horns	1887
Pepion	L	1897
Pepion	Laura	1904
Pepion	Le Roger	1911
Pepion	Leroy	1908
Pepion	Louise	
Pepion	Louise	
Pepion	Louise	
Pepion	Louise	1877
Pepion	Louise	
Pepion	Lucile	1910
Pepion	Lydia	1915
Pepion	Mabel	
Pepion	Mamie	1907
Pepion	Mary	1899
Pepion	Nora	
Pepion	Polite	
Pepion	Polite	
Pepion	Polite	
Pepion	Polite	1906
Pepion	Polite	1862
Pepion	Ray	1917
Pepion	Theo	1913
Pepion	Thomas	1894
Pepion	Verna May	1919
Pepion	Veronica	1917
Pepion	Victor	1906
Pepion	Victor H.	1895
Pepion	Wilbur	1915
Pepion	Willard	1915
Percival	Angeline	1910
Percival	Bernice Elizabeth	1907
Percival	E. L.	1910
Percival	Ernest L.	1910
Perrine	George	
Perrine	George	
Perrine	George	
Perrine	George	1898
Perrine	Irene	1905
Perrine	James	
Perrine	James A	
Perrine	James A.	1872
Perrine	James A. Jr.	1915
Perrine	James F.	1900
Perrine	John	1909
Perrine	Mary	1870
Perrine	Minnie	1901
Perrine	Minnie	1872
Perrine	Patsy	1909
Person Gives Things To Sun	Dick	1880
Person Gives Things To Sun	Jaine	1879
Person Gives Things To Sun	Jessie	1883
Person Gives Things To Sun	Johnny	1876
Person Gives Things To Sun	Susie	1886
Peterson	Charles	
Peterson	Charles Louis	
Peterson	Frank	1884
Peterson	Gloria	1886
Peterson	Irvin	1911
Peterson	Lizzie	
Peterson	Lizzie Henkle	
Peterson	Maggie	
Peterson	Marguerite	
Peterson	Margurite	1861
Peterson	May	1906
Peterson	Melton	1883
Peterson	Melvin	1886
Peterson	Mitchell	1888
Peterson	Mrs.	
Peterson	Oscar	1880
Peterson	Selma	1915
Peterson	Stratford Browning	1913
Peterson	Walter	1882
Phemister	Helen	
Phemister	Hellen	1905
Phemister	James	1874
Phemister	Mary Jane	1851
Pias	Kate	
Pias	Katie	
Pias	Katie	1891
Pias	Maggie	1882
Pias	Mary	1885
Pias	Reuben	1883
Pias	Rosa	1861
Pias	Ruth	1891
Pias	Sophia	1890
Pias	Susan	1917
Pias	Tony	1888
Pickney	Lucy Aubrey	
Pickney	Thelma Helen	1913
Piegan	Ezra	1888
Pierre	Eugene	
Pierre	Eugene Elmer	1914
Pierre	John Theodore	1913
Pierre	Lawrence Leo	1916
Pierre	Mary Isabell	1918
Pierre	Mary M.	1894
Plenty Butterflies	George	1876
Plenty Butterflies	Mary	1884
Plume	Samuel	1871
Pokska	Paul	1866
Poktt	Cecille	1910
Poktt	Henry	1910
Poktt	Mary Virginia	1847
Polite	Cecil	1871
Polite	Cecil	1875
Polite	Cecile	
Polite	Chester	1883
Polite	Frank	1881
Polite	John	1871
Polite	Louise	1877
Poor Woman	Frank	1875
Potts	Cecile	1901
Potts	Charles	1888
Potts	James	1911
Potts	Jerry	1899
Potts	Joe	
Potts	Joseph	1875
Potts	Mary Pablo	1898
Powell	Allen	1907
Powell	Anna	1885
Powell	Annie	
Powell	Ashley Q	1916
Powell	Ashley Q.	1916
Powell	Charles	1876
Powell	Charles Jr.	1911
Powell	Claire	1891
Powell	Eldon W.	1909
Powell	Ellen	1897
Powell	Frank	1896
Powell	Henry	1904
Powell	Henry Ampton	
Powell	Hunter	1860
Powell	James	1907
Powell	Jesse J.	1906
Powell	Jessie	1882
Powell	John	1876
Powell	Lucy	1886
Powell	Maggie	1885
Powell	Mary	
Powell	Mary	
Powell	Mary	1859
Powell	Mary	1904
Powell	Mary	1854
Powell	Mary V.	1879
Powell	Richard	1884
Powell	Sophia	1873
Powell	Susan	1886
Power	John	1828
Prairie Chicken Shoe	Frank	1888
Prairie Chicken Shoe	Louis	1894
Prairie Chicken Shoe	Mary	1892
Prairie Chicken Shoe	Susie	
Prairie Chicken	Cecil	1896
Prairie Chicken	George	1873
Prairie Chicken	Jennie	1880
Prairie Chicken	Sam	1899
Pretty Blanket Woman	Lucy	1889
Pretty Hawk Woman	Mary	1897
Pretty Hawk	Mary	1883
Prev Marr - Yes	Before Apr 1913	
Previous Marr: Yes	Widow	
Prince	Abba	
Prince	Charles	
Prince	J. E.	1861
Prince	Lillie	1890
Prince	Sophia	1889
Racine	Aaron	1905
Racine	Abel	1910
Racine	Albert	1903
Racine	Andrew H.	1912
Racine	Baptiste	
Racine	Baptiste	
Racine	Baptiste	1891
Racine	Baptiste	1907
Racine	Belle	
Racine	Elva	1919
Racine	Eugene Ernest	1905
Racine	Frank	1899
Racine	Frank B.	1880
Racine	Henritta	1909
Racine	Henry	1901
Racine	Herbert Carl	1914
Racine	Hildegarde	1917
Racine	Irene	1912
Racine	Irene Louise	1910
Racine	Joseph	1896
Racine	Josephine	1907
Racine	Julia	1847
Racine	Melvina	1899
Racine	Murel	1917
Racine	Nettie	1883
Racine	Oliver	
Racine	Oliver Aloysius	1914
Racine	Oliver C.	
Racine	Oliver C.	1879
Racine	Oliver Carl	1914
Randall	Bertha	1906
Randall	Dewey Anthony	1913
Randall	Geneva	1915
Randall	Isabell	
Randall	Isabelle	1888
Randall	Louis	1911
Randall	Louise	1907
Randall	Sam	
Randall	Tobell	
Rasmussen	Anthony Randall	1914
Rattler	Ekmer	
Rattler	Elmer	1875
Rattler	Minnie	88
Rattler	Minnie K.	
Rattler	Philip	1910
Rattling At One Another	Thomas	1875
Red Bird Tail	Maggie	1891
Red Bird Tail	Margaret	
Red Bird Tail	Margaret	1909
Red Bull	Katie	
Red Calf	Anna	1884
Red Fox	Annie	1906
Red Fox	Charles	1895
Red Fox	Child	
Red Fox	Jack	1916
Red Fox	James	1897
Red Fox	John	1895
Red Fox	Lucy	1902
Red Fox	Mary	1902
Red Fox	Mary Louise	1911
Red Fox	Minnie	1905
Red Fox	Sarah	1917
Red Fox	Susie	1917
Red Fox	Thecla	1916
Red Head	Daniel	1884
Red Head	George	1919
Red Head	John	1897
Red Head	Lawrence	1860
Red Head	Nancy	1897
Red Horn	Isabell	1871
Red Horn	Jack	1874
Red Horn	Joseph	1916
Red Horn	Peter	1915
Red Top	John	1894
Redfox	Aloysius	1914
Reed	Isaac Charles	1877
Reevis	Agnes	1913
Reevis	Augustine	1879
Reevis	Cecile	1897
Reevis	Charles	1873
Reevis	Charley	
Reevis	Charlie	1877
Reevis	Clara	1913
Reevis	Elizabeth	1868
Reevis	Emma	1884
Reevis	Emmett	1881
Reevis	Francis	1886
Reevis	Henry	1906
Reevis	James	1903
Reevis	Joseph	1898
Reevis	Julia	1859
Reevis	Louis	
Reevis	Louis	
Reevis	Louis	
Reevis	Louis	
Reevis	Louis	
Reevis	Louis	1896
Reevis	Louis	1908
Reevis	Louise	
Reevis	Maggie	1911
Reevis	Susie	1899
Remsa	Jesse	1895
Remsa	Mary	1875
Revis	Henry	1910
Richie	Maymie	1915
Rider Down	Anna	1889
Rider Down	Johnny	1879
Rider Down	Pete	1886
Rider Down	William	1883
Rider	Angeline	
Rider	Cecilia	1908
Rider	Child	
Rider	Eli	
Rider	Eli	
Rider	Eli	1899
Rider	Eli	1899
Rider	Eli	1873
Rider	Eli	1887
Rider	Frank	
Rider	Frank	
Rider	Frank	
Rider	Frank	
Rider	Frank	
Rider	Frank	1866
Rider	Frank	1867
Rider	George	1917
Rider	Gretchen	1871
Rider	Henry	1896
Rider	James	1903
Rider	Maggie	
Rider	Maggie	1912
Rider	Maggie	1883
Rider	Mary	1896
Rider	Morgan	1919
Rider	Sam	1911
Rider	Susan	1899
Rides At Door	James	1897
Rides At Door	Louise	1892
Rides At Door	Mary	
Rides At Door	Richard	1890
Rides At The Door	Aloysius	1917
Rides At The Door	Amy	1885
Rides At The Door	Anna	1908
Rides At The Door	Edith	1910
Rides At The Door	Emma	1918
Rides At The Door	Ethel	1914
Rides At The Door	Frank	1894
Rides At The Door	Grant	1916
Rides At The Door	John	1899
Rides At The Door	Joseph	1903
Rides At The Door	Mary	
Rides At The Door	Richard	1908
Rides At The Door	Rose Cecilia	1913
Rides At The Door	Thelma	1913
Rides At The Door	William	1903
Rides Behind	Emma	1879
Rides In The Middle	Annie	
Rides In The Middle	Mary	1892
Ripley	Belle	1843
Ripley	David	1877
Ripley	Mary	1873
Ripley	Minnie	1882
Ripley	Minnie	1881
Robare	Henry	1862
Robare	Martha	1823
Robart	Martha Cadotte	
Robergen	Mary	
Roberger	Mary	1909
Roberts	George	1917
Roberts	Mary	1861
Robinson	Agnes	1890
Robinson	Allen	1895
Robinson	Annie	1863
Robinson	Charles	1888
Robinson	Geneva	1916
Robinson	George	1876
Robinson	James	1893
Robinson	Joe	1882
Robinson	Louise	1889
Robinson	Mary	1878
Robinson	Verne	1920
Robinson	Vic	1858
Roche	Emma	
Romsa	Jesse	1897
Romsa	Jesse H.	
Romsa	Melvin	1898
Rondi	Charles	1910
Rondi	Isabel	
Rondi	Isabelle	1910
Rondin	Annie	1893
Rondin	Baptist	
Rondin	Baptist 1	
Rondin	Baptiste	
Rondin	Baptiste 1	1862
Rondin	Baptiste 2	1885
Rondin	Isabel	1896
Rondin	Joseph	1911
Rondin	Joseph	1882
Rondin	Louise	1888
Rondin	Mabel	1887
Rondin	Mary	
Rondin	Mary	
Rondin	Mary	
Rondin	Mary	1888
Rondin	Mary	1888
Rondin	Mary	1862
Rondin	Nancy	1894
Rondin	Richard	1878
Rondin	Samual	1886
Rondin	Susie	1892
Rose Old Man Chief	Rose	1919
Rose	Agnes	1858
Rose	Alice	1889
Rose	Annie	1902
Rose	Annie	1893
Rose	Charles	
Rose	Charley	1859
Rose	Clara	1893
Rose	Elizabeth	1896
Rose	Geneva	1918
Rose	Helen	1912
Rose	Ida	1908
Rose	Joe	1904
Rose	Julia	1886
Rose	Julia	1885
Rose	Louise	1912
Rose	Maggie	1881
Rose	Mary	1888
Rose	Millie	1916
Rose	Peter	1891
Rose	Susie	1916
Rose	William	1890
Roth	Rosa	1874
Round Man	Raymond	1908
Round	Lilly	1887
Roy	Leo	1893
Run Rough	Louise	
Running Crane	Annie	1901
Running Crane	Cecile	1910
Running Crane	Charley	1915
Running Crane	Eddie	1874
Running Crane	Eddy	1895
Running Crane	Edward	1895
Running Crane	Isabell	
Running Crane	James	1888
Running Crane	John	
Running Crane	John	1884
Running Crane	John	1884
Running Crane	John	1887
Running Crane	Joseph	1915
Running Crane	Joseph	1911
Running Crane	Joseph	1886
Running Crane	Louis	1891
Running Crane	Louise	1902
Running Crane	Maggie	1900
Running Crane	Maggie	1887
Running Crane	Mamie	1886
Running Crane	Mary	1917
Running Crane	Mary	1913
Running Crane	Mary	1883
Running Crane	Nancy	1883
Running Crane	Nellie	1879
Running Crane	Paul	1899
Running Crane	Peter	1897
Running Crane	Philip	1919
Running Crane	Sarah	1919
Running Crane	Theresa	1916
Running Crane	Thomas	1916
Running Crane	William	1906
Running Crow	Jack	
Running Eagle	Minnie	1859
Running Fisher	Albert	1891
Running Fisher	Carrie	1860
Running Fisher	Dolerese	1894
Running Fisher	Dolorese	1906
Running Fisher	Irene	1883
Running Fisher	John	1893
Running Fisher	Mary	1891
Running Owl	Angeline	1917
Running Owl	Joseph	1891
Running Owl	Lucy	1891
Running Owl	Rosie	1886
Running Owl	Round Robe	
Running Rabbit	Annie	1897
Running Rabbit	Guy	1876
Running Rabbit	Hester	1824
Running Rabbit	Isabelle	1889
Running Rabbit	John	1895
Running Rabbit	Julia	1886
Running Rabbit	Maggie	
Running Rabbit	Mary	1892
Running Rabbit	Mike	1906
Running Rabbit	Thomas	1905
Running Rabbit	William J.	1910
Running Wolf	Anna	1909
Running Wolf	Annie	1909
Running Wolf	Cloteldia	1884
Running Wolf	George	
Running Wolf	Henry	1914
Running Wolf	Herbert	1885
Running Wolf	Homer	1885
Running Wolf	Horace	1919
Running Wolf	John	1894
Running Wolf	Joseph	1910
Running Wolf	Laura	1916
Running Wolf	Lawrence	1918
Running Wolf	Lawrence	1910
Running Wolf	Louise	1912
Running Wolf	Mary	1909
Running Wolf	Miles	1883
Running Wolf	Myles	
Running Wolf	Pearl	1917
Running Wolf	Richard	1913
Running Wolf	Tina	1917
Runs Away	Mary	1882
Runs Away	Michael	1894
Runs Away	Susan	1891
Rushing Back	Peter	1879
Russell	Alice Agnes F.O.	1915
Russell	Cecile	1882
Russell	Cecile	1882
Russell	Charles	1872
Russell	First One	1871
Russell	Frances	1889
Russell	Francis	1917
Russell	Frank	1886
Russell	George	1885
Russell	Henry	1897
Russell	Isabel	1882
Russell	Isabelle	1907
Russell	Joe	1919
Russell	John	1902
Russell	John T.	1910
Russell	Joseph	1887
Russell	Joseph First One	1901
Russell	Louise	
Russell	Louise	1901
Russell	Louise	1875
Russell	Mary	1858
Russell	Peter	1910
Russell	Petrified	1830
Russell	Susie	1877
Russell	Virginia	1904
Russell	William	
Russell	William	
Russell	William	
Russell	William	
Russell	William	
Russell	William	
Russell	William	
Russell	William	
Russell	William	1908
Russell	William	1855
Russell	William 2	1890
Rutherford	Abe	1912
Rutherford	Alice	
Rutherford	Alice	1877
Rutherford	Alice	1880
Rutherford	Dewey	
Rutherford	Edna	1898
Rutherford	Eliza	1876
Rutherford	Gladys Hattie	1912
Rutherford	Henry	1888
Rutherford	James	1906
Rutherford	James	1904
Rutherford	James	1886
Rutherford	James C.	
Rutherford	Lorena	1917
Rutherford	Martha	1873
Rutherford	Mary	
Rutherford	Mary	
Rutherford	Mary	
Rutherford	Mary	
Rutherford	Mary	1881
Rutherford	Mary	1875
Rutherford	Mary	1856
Rutherford	Mary Or Chub	
Rutherford	Melvin	1906
Rutherford	Olive	1917
Rutherford	Pansy	1913
Rutherford	Priscilla Genevive	1911
Rutherford	Richard	1878
Rutherford	William	
Rutherford	William	1910
Rutherford	William	1910
Rutherford	William	1915
Rutherford	William	1883
Rutledge	Joe	
Rutledge	Mary	1888
Rye	Stanley	1887
Rye	Susan Wren Cone	1904
Saber	Isabelle	1861
Saber	John	1892
Saber	Julia	1890
Sallew	Margaret	1879
Sallew	William R.	1879
Salway	Charles	1920
Salway	Harry	1916
Salway	Maggie	1918
Salway	Philip	1912
Salway	Samuel	1913
Samples	A.P.	1846
Samples	Alma	1905
Samples	Eliza	1851
Samples	Elsie	1896
Samples	Emily Louise	1916
Samples	Florence	1895
Samples	Jesse	
Samples	Jesse J.	
Samples	Jessie	1873
Samples	Jessie J.	
Samples	Julia	1893
Samples	Lavina	1878
Samples	Mary	
Samples	Mary	
Samples	Mary	1896
Samples	Mary	1873
Samples	Melba	1900
Samples	Rosia	1907
Samples	Sarah	1886
Samples	Stella	1895
Samples	William	
Samples	William	
Samples	William	1896
Samples	William	1868
Samples	William A.	
Samples	William Jr.	1893
Sandervill	Bridget	1916
Sanderville	Agnes	1888
Sanderville	Alfred B.	1885
Sanderville	Annie	
Sanderville	Bridget	
Sanderville	Cecelia	1869
Sanderville	Claudie	1889
Sanderville	Dick	1867
Sanderville	Ellen	
Sanderville	Helonise	1872
Sanderville	Irene	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	
Sanderville	Isadore	1909
Sanderville	Isadore	1909
Sanderville	Isidore	
Sanderville	Isidore	1909
Sanderville	Isidore	1900
Sanderville	John	1887
Sanderville	Louise	1872
Sanderville	Margaret	
Sanderville	Martha	1911
Sanderville	Mary	
Sanderville	Mary 2	
Sanderville	Nancy	1873
Sanderville	Nellie	
Sanderville	Oliver	1860
Sanderville	Oliver 1	
Sanderville	Oliver 2	1887
Sanderville	Richard	1867
Sanderville	Richard N.	1918
Sanderville	Thomas	
Sanderville	Thomas	
Sanderville	Thomas	
Sanderville	Thomas	1860
Sanderville	Thomas	1858
Sanderville	William	1896
Sangry	Louis	1875
Sangry	Mary	
Sangry	Matthews	
Sansavare	Dorothy	1917
Sansavare	Roderick	1916
Sansavere	Josephine	1919
Santana	Arturo	
Savage Piegan	Julia	1895
Savage Piegan	Silly	
Scabby Person	Elisa	1875
Scabby Robe	Alice	1914
Scabby Robe	Annie	1915
Scabby Robe	Cecile	1886
Scabby Robe	Dave	1890
Scabby Robe	David	1922
Scabby Robe	Elizabeth	
Scabby Robe	Joe	1894
Scabby Robe	Joseph	1913
Scabby Robe	Joseph James	1917
Scabby Robe	Louise	1910
Scabby Robe	Marie	1910
Scabby Robe	Mary Florence	1911
Scabby Robe	Sam	
Scabby Robe	Sam	
Scabby Robe	Sam	
Scabby Robe	Sam	
Scabby Robe	Sam	1879
Scabby Robe	Sonny	1889
Schildt	Andrew	1889
Schildt	Andrew H.	
Schildt	Andrew Jr.	1915
Schildt	Augusta	1891
Schildt	Augusta R.	1908
Schildt	Carroll	1895
Schildt	Cecile	1903
Schildt	Cecilia	
Schildt	Edith	1902
Schildt	Emmet	1912
Schildt	Florence	1916
Schildt	Francis	
Schildt	Harry	1881
Schildt	Harry A.	1852
Schildt	Henry	
Schildt	Henry	
Schildt	Henry	
Schildt	Henry	
Schildt	Henry	1885
Schildt	Irene	1896
Schildt	Joseph	
Schildt	Joseph	1881
Schildt	Louise	1923
Schildt	Mary	
Schildt	Mary	
Schildt	Mary	
Schildt	Mary	1909
Schildt	Mary	1893
Schildt	Nellie	1867
Schildt	Nettie	1886
Schmidt	Alex	1851
Schmidt	Carl	
Schmidt	Carl J.	
Schmidt	Carl J. Jr.	1910
Schmidt	Carrol	1876
Schmidt	Carroll	
Schmidt	Charles	1917
Schmidt	Charles Asa	1917
Schmidt	Clara	
Schmidt	Clara H.	
Schmidt	Clara K.	1879
Schmidt	Ethel	1899
Schmidt	Florence Margeret	1907
Schmidt	George	1879
Schmidt	George Augustus	1914
Schmidt	Gladys	1901
Schmidt	Jacob	1908
Schmidt	Jeannie	1880
| M.1897
Schmidt	Leonard	1902
Schmidt	Margaret	
Schmidt	Merlyn	1910
Schmidt	Rosa	1908
Schmidt	Rose	1900
Schmidt	Rosie	1882
Schmidt	Violet	1911
Schubert	Agnes	1891
Schultz	H.	
Schultz	Hart	
Schultz	Hart	
Schultz	James Willard	1947
Schultz	Jessie Donaldson	
Sciaccoti	Frank Woodrow	1918
Scissors Woman	Cecile	1888
Scott	Grace	
Scraper	Jimmy	1884
Seal Woman	Anna	1888
Selecman	Francis	1914
Selinski	Harold	1919
Sellars	A. B.	
Sellars	A. R.	
Sellars	A.B.	
Sellars	Anna	
Sellars	Anna C.	
Sellars	Monica Marie	1915
Sellars	Thomas George	1916
Sellen	Clara	1898
Sellen	Maggie	1865
Sellen	Margaret	1879
Sellen	Ralph	1896
Sellew	Clara	1915
Sellew	George C.	1902
Sellew	Philip	1897
Setting Behind	Rosa	1888
Seymour	Charlotte E.	
Shannon	Ellen	1909
Shannon	Mary	
Shannon	Patrick	1909
Sharp	Angus	1905
Sharp	Charlotte	1912
Sharp	Jack	1901
Sharp	John	1907
Sharp	Julia	1898
Sharp	Justus	1897
Sharp	Rosa	1877
Sharp	Rose	
Sharp	William	
Shay	William	
She Had A Tooth Before	Angeline	1899
She Had Tooth Before	Angeline	
Sheman	Amy	
Sheppard	Newton	
Sherburne	Agnes	1916
Sherburne	Cara	1911
Sherburne	Faith	1914
Sherburne	J. L.	
Sherburne	Mrs.	
Sherburne	Mrs. J. L.	
Sherburne	Theodosia	1920
Sheriff	Anna	1912
Sheriff	Jack H.	1908
Sheriff	Mary Isabelle	1915
Sheriff	Ora	
Sheriff	Orrie	1876
Sheriff	Orrie Aka Haggerty	Orrie	1909
Sheriff	Rose	
Sheriff	Rosie	
Sherman	Albert	1905
Sherman	Alex	
Sherman	Alexander	
Sherman	Alexander	1901
Sherman	Alexander	1909
Sherman	Alexander	1882
Sherman	Amy	1908
Sherman	Catherine	1916
Sherman	Charles	1895
Sherman	Charles	1875
Sherman	Emma	1911
Sherman	Emma	1885
Sherman	Geneva	
Sherman	Genevieve	1880
Sherman	Genivieve	
Sherman	Joseph	1901
Sherman	Katie	
Sherman	Martin	1897
Sherman	Mary	1896
Sherman	Nellie	1878
Sherman	Rena	
Sherman	Robert	1882
Sherman	Sophia	
Sherman	Sophia	
Sherman	Sophia	
Sherman	Sophia	1909
Sherman	Sophia	1885
Sherman	Susan	
Sherman	Susan Malgum	1856
Sherman	Susan Williamson	
Sherman	William	
Sherman	William	
Sherman	William	
Sherman	William	
Sherman	William	
Sherman	William	
Sherman	William	
Sherman	William	
Sherman	William	1872
Sherman	William	
Sherman	William	1871
Sherman	William Alex	1915
Sherman	Wilson M.	1913
Shields	Esther May	1915
Shields	Richard F.	
Shoots Another	Irene	1899
Shoots Another	William	
Shoots Close	George	1894
Shoots Close	James	1892
Shoots Close	John	1894
Shoots First	Cecile	1895
Shoots First	Henry	1884
Shoots First	Joseph	1899
Shoots First	Maggie	1895
Shoots First	Mary	1888
Shoots First	Nellie	1895
Short Face	Anna	1915
Short Face	John	1891
Short Face	Joseph	1912
Short Face	Rosie	1917
Short Face	Susan	
Short Man	John	1889
Short Man	Louise	1868
Short Man	Mike	1854
Short Man	Sophronia	
Short Man	Victoria	1869
Short Robe	Annie	1889
Short Robe	Cecile	1894
Short Robe	Emma	1894
Short Robe	John	1896
Short Robe	Joseph	1905
Short Robe	Mary	1908
Short Robe	Mike	1904
Short Robe	Ralph	1892
Short Robe	William	1911
Short Woman	Johnny	1886
Short Woman	Louise	1880
Short Woman	Mary	1880
Short Woman	Susan	1889
Shorty	Catherine	1906
Shorty	Cora	1889
Shorty	George	1908
Shorty	Isabell	
Shorty	Isabell	
Shorty	Isabell	1901
Shorty	Isabell	1876
Shorty	Joe	1868
Shorty	John	
Shorty	John	
Shorty	John	
Shorty	John	
Shorty	John	
Shorty	John	
Shorty	John	
Shorty	John	1861
Shorty	Johnny	1888
Shorty	Joseph	1888
Shorty	Kitty	1890
Shorty	Louis	1893
Shorty	Lucy	1895
Shorty	Maggie	1886
Shorty	Mary	
Shorty	Mary	
Shorty	Mary	
Shorty	Mary	1886
Shorty	Mary	
Shorty	Mary	1863
Shorty	Mary	1870
Shorty	Mary Ann	1886
Shorty	Rosie	
Shorty	Ross	1886
Shorty	Sallie	1902
Shorty	Sam	1889
Shorty	Steve	1913
Shorty	Susan	1891
Shorty	Susanne	
Shorty	White Grass	
Shultz	Hart	
Shultz	Isabell	1886
Shultz	Margaret	1888
Shultz	Susan	1865
Silvan	Josephine	1878
Simeneaux	Emily	1909
Simon	Annie Tatsey	
Simon	Charles	1861
Simon	Josephine	1871
Simon	Maggie	1859
Simon	Mamie	1877
Simon	Mary	1889
Simon	Monic	
Simons	John	1909
Simons	Monic	
Simpson	Eugene G.	1915
Simpson	Lucille Mary	1913
Simpson	W. F.	
Singing Under	Antoine	1885
Skunk Cap	Able	1875
Skunk Cap	Alonzo	1889
Skunk Cap	Anna	1914
Skunk Cap	Charles	1876
Skunk Cap	James	1913
Skunk Cap	Joseph	1871
Skunk Cap	Josephine	1919
Skunk Cap	Josephine	1911
Skunk Cap	Minnie	1886
Skunk Cap	Norah	1917
Skunk Cap	Paul	1866
Skunk Cap	Rosa Lucy	1895
Skunk Cap	Rose Lucy	1910
Skunk Cap	Sammy	1871
Sleeping Wolf	Lucy	1883
Slim Tail	Rosie	1851
Slim Tail	Tom	1886
Sloan	Robert	
Small Face	Jacob	1886
Small Leggings	Joseph	1890
Small Snake	Mary	
Small Wolf	Fransis	1877
Small Wolf	Joseph	1888
Small Wolf	Maggie	1886
Small Woman	Annie	1886
Small Woman	Minnie	1888
Small	Daisy	1879
Smith	Aloysa	1880
Smith	Amy	1902
Smith	Anna	1893
Smith	Annie	1915
Smith	Bally	1884
Smith	Belle	1884
Smith	Denzal Wilken	1915
Smith	Dorothy	1918
Smith	Elsie	1905
Smith	Emma	1883
Smith	Emma A.	
Smith	Eveline	1907
Smith	George	1906
Smith	Joseph Almer	1919
Smith	Julia	1910
Smith	Julia	1903
Smith	Julia	
Smith	Katie	1880
Smith	Kenneth	1916
Smith	Lester	1916
Smith	Lillie	1913
Smith	Lizzie	1843
Smith	Mary	1898
Smith	Mary	1877
Smith	Mary Elinor	1911
Smith	Matilda	1878
Smith	Monica	
Smith	Paul	
Smith	Peter	1885
Smith	Peter Isaac	1913
Smith	Peter Samie Perry	1907
Smith	Rosa	1905
Smith	Ruby	1907
Smith	Sam	
Smith	Samuel	1881
Smith	Susie	1883
Smith	Thelma	1913
Smith	Theodore Nelson	1915
Smith	Viola	1883
Smith	William	
Smith	William	
Smith	William	
Smith	William	
Smith	William	
Smith	William	
Smith	William	
Smith	William	
Smith	William	
Smith	William	1874
Smith	William	1879
Smith	William B.	
Smith	William Jr.	1911
Smoking Flint	Louis	1895
Snow	Mary	1900
Snyder	Olive	1921
Soose	Chick	1855
Soose	Margrete	1868
Soose	Margrete Luis	1890
Spaniard	Peter	1871
Spanish	Eugene	1914
Spanish	Evelyn Marie	
Spanish	Joseph	
Spanish	Joseph	
Spanish	Joseph	
Spanish	Joseph	
Spanish	Joseph	1867
Spanish	Joseph	1874
Spanish	Margaret	
Spanish	Margaret	
Spanish	Margaret	
Spanish	Margaret	1860
Spanish	Myrtle	1917
Spanish	William	
Spanish	William	
Spanish	William	1915
Spanish	William	
Spanish	William	1893
Spanish	William	
Spearson	Alfred	1892
Spearson	Emily	1867
Spearson	Frank	
Spearson	Frank	
Spearson	Frank	
Spearson	Frank	1849
Spearson	Frank	1856
Spearson	Got Gun Inside	1896
Spearson	Maria	1882
Spearson	Mary	
Spence	Mary	
Spence	Molly	1908
Spencer	Sarah	
Split Ears	Jane	1906
Split Ears	Maggie	89
Spotted Bear	Agnes	
Spotted Bear	Agnes	
Spotted Bear	Agnes	
Spotted Bear	Agnes	1918
Spotted Bear	Agnes	
Spotted Bear	Anna	
Spotted Bear	Annie	
Spotted Bear	Annie	
Spotted Bear	Annie	1882
Spotted Bear	Annie	1879
Spotted Bear	Batiste	1878
Spotted Bear	Charles	1913
Spotted Bear	Dora	1914
Spotted Bear	George	1903
Spotted Bear	Hattie	1916
Spotted Bear	James	1908
Spotted Bear	Joe	1891
Spotted Bear	John	
Spotted Bear	John	1893
Spotted Bear	Kate	1900
Spotted Bear	Louise	1910
Spotted Bear	Maggie	1873
Spotted Bear	Mary	1916
Spotted Bear	Mary	1876
Spotted Bear	Mike	1897
Spotted Bear	Minnie	1889
Spotted Bear	Perry	1888
Spotted Bear	Pet	1891
Spotted Bear	Peter	1879
Spotted Bear	Philip	1903
Spotted Bear	Rose	1916
Spotted Bear	Rosie	1898
Spotted Bear	Samuel	1911
Spotted Eagle	Agnes	1919
Spotted Eagle	Annie	1918
Spotted Eagle	Clara	1915
Spotted Eagle	Dick	1913
Spotted Eagle	Francis Xavier	1908
Spotted Eagle	Fransis	1908
Spotted Eagle	Irene	1911
Spotted Eagle	Jack	1886
Spotted Eagle	James	
Spotted Eagle	James	1900
Spotted Eagle	James	1918
Spotted Eagle	James	
Spotted Eagle	James	
Spotted Eagle	James	1879
Spotted Eagle	Joe	1912
Spotted Eagle	John	1883
Spotted Eagle	Joseph	1892
Spotted Eagle	Julia	1903
Spotted Eagle	Lucy	
Spotted Eagle	Lucy	1876
Spotted Eagle	Martha	1908
Spotted Eagle	Mary	1909
Spotted Eagle	Mary Agnes	1910
Spotted Eagle	Matilda	1883
Spotted Eagle	May	1881
Spotted Eagle	Perry	1911
Spotted Eagle	Rachael	1890
Spotted Eagle	Thomas	
Spotted Eagle	Tom	1873
Spotted Eagle	William	1913
Spotted Head	Mary	1873
Spotted Wolf	Angeline	1919
Spotted Wolf	Geneva	1915
Spotted Wolf	John	1877
Spotted Wolf	Patronella	1917
St Goddard	Agnes	
St Goddard	Alimina	1915
St Goddard	Aliminia	1895
St Goddard	Almena	
St Goddard	Archibald	1897
St Goddard	Maxine	1909
St Goddard	Osa	
St Goddard	Philomene	
St Goddard	Pholeminie	
St. Goddard	Agnes	1890
St. Goddard	Almena	1920
St. Goddard	Maxine	
St. Goddard	Osa	1890
St. Goddard	Philhomena	1890
St.Goddard	Agnes	
St.Goddard	Almena	
Stabs By Mistake	John	1910
Stabs By Mistake	Maggie	1892
Stabs By Mistake	Peter	1883
Stabs By Mistake	Thomas	1889
Stabs Down	Arthur	
Stabs Down	Louise	
Stabs Down	Mary	1888
Stabs Down	Mrs	1908
Stabs Down	Sam	1909
Stabs Down	William	1900
Stakt Si Nes Skim	Mary	
Stapleton	Miss Ione Virginia	1916
Star	Christian	1895
Star	Ellen	1888
Star	George	1868
Star	Lora	1897
Star	Maggie	1879
Star	Pablo	
Starr	George	
Starr	Isabel Cooper	
Starr	Isabelle Main	1904
Starr	Pablo	1910
Steel	George	1916
Steele	Daisy	1915
Steele	Edgar M.	
Steele	James	
Steele	James	
Steele	James	
Steele	James	
Steele	James	
Steele	James	1912
Steele	James	
Steele	La Vern	1919
Steele	La Von	1919
Steele	Leverne	1919
Steele	Levon	1919
Steele	Millie	1883
Steele	Mrs. James	
Steele	Roy	1900
Steele	Sarah	1909
Stele	Millie	
Stephenson	George	
Stephenson	Kate	
Stephenson	Phoebe	1918
Stevenson	Amy	1890
Stevenson	Annie	1889
Stevenson	George	
Stevenson	Henry	1886
Stevenson	Kate	
Stevenson	Katie	1869
Stevenson	Laura	1883
Stevenson	Orcelia	1913
Stevenson	Phoebe	1895
Steward	Carrie	1881
Steward	Cecil	1893
Steward	Clara	1885
Steward	Jennie	1883
Steward	Maria	1896
Steward	Mary	1864
Steward	Nellie	1887
Stewart	Barbara	
Stewart	Calvin	1859
Stewart	Carl	1891
Stewart	Cecile	
Stewart	Charles	
Stewart	Earl	
Stewart	Evelin	1916
Stewart	Florence Katrine	1918
Stewart	Geneva	1870
Stewart	George W.	1893
Stewart	Georgia	
Stewart	Honey	
Stewart	James	1884
Stewart	James Tom	
Stewart	Jennie	1884
Stewart	Jim	1895
Stewart	Jimmie	
Stewart	Joe	1880
Stewart	John K.	1909
Stewart	John W.	
Stewart	Joseph	
Stewart	Julia	1886
Stewart	Mary	
Stewart	Mary	
Stewart	Mary	
Stewart	Mary	1882
Stewart	Mary	1860
Stewart	Maylon	
Stewart	Nancy	1909
Stewart	R0bert	
Stewart	Robert	
Stewart	Robert S.	1900
Stewart	Ruth	
Stewart	Thomas	1888
Stewart	Vera	1897
Stewart	Violet	
Stewart	Virgina	
Stewart	Virginia	1894
Stewart	William	1909
Still Smoking	Annie	1903
Still Smoking	Joe	
Still Smoking	Joseph	
Still Smoking	Joseph	
Still Smoking	Joseph	1900
Still Smoking	Joseph	1889
Still Smoking	Mary	1906
Still Smoking	Minnie	
Still Smoking	Samuel	1907
Still Smoking	Susan	1899
Still Smoking	William	1910
Stingy	James	
Stingy	James	1919
Stingy	James	1893
Stingy	Mary	1902
Stink Teat	John	1889
Stink Teat	Ruth	1881
Stink Tit	Rose	1896
Stink Tit	Ruth	
Stone	Dewey	1920
Stone	Earl	1918
Stone	Flurry	1917
Stone	Frank	1895
Stone	Fred	1903
Stone	Henry	1894
Stone	James	
Stone	Joseph	1895
Stone	Mary	1866
Stone	Miss Julia A.	1920
Stone	Robert	1890
Strangle Wolf	Johnny	1872
Strangle Wolf	Mary	1878
Straw	Anna	1893
Strikes Back	Annie	1883
Strikes Back	Antoine	1892
Strikes Back	John	1886
Strikes Back	Josiah	1882
Strikes Back	Victoria	1887
Strikes By Mistake	Anna	1876
Strikes Close	Susie	1891
Strikes First	Mary	1874
Strikes First	Mary Rondin Baptist	1874
Strikes Together	Joseph	1881
Strikes Together	Paul	1884
Strikes	Annie	1892
Strikes	Joe	1888
Striking Back	Isabel	1881
Striking Back	Victor	1891
Striking Flint	Jimmy	1891
Stuart	Caroline	1877
Stuart	Cecilia	1891
Stuart	Dorothy	1915
Stuart	Earl	1874
Stuart	Helen	1854
Stuart	Jennie	1911
Stuart	Joseph	
Stuart	Mabel	1884
Stuart	Marion	
Stuart	Mary	
Stuart	Mollie	1888
Stuart	Thomas	1882
Stuart	Vivian	1891
Suce	Antoine	1890
Sullivan	Dora Agnes	1878
Sullivan	Josephine	1874
Sullivan	Mollie	1869
Sundown	Annie	1876
Sundown	Jackson	
Sure Chief	George	1902
Sure Chief	Mollie	1919
Sure Chief	Philip	
Sure Chief	Rose	1908
Sure Chief	William	
Surefire	Eliza	1883
Swims Under	John	1913
Swims Under	Lizzie	1895
Swims Under	Maggie	
Swims Under	Maggie	1883
Swims Under	Maggie	1907
Swims Under	Mary	1895
Swims Under	Mike	1914
Swims Under	Susie	1910
Swims Under	Thomas	1893
Swingley	Belle Arnoux	
Swingley	Beverly	1915
Swingley	 H.	
Swingley	Douglas	
Swingley	Ed	
Swingley	Edward	1916
Swingley	Louis	1914
Swingley	Meade	1917
Swingley	Merle	1917
Swingley	Ruby Bevin	1912
Tabor	Agnes	1912
Tabor	James	1916
Tabor	John Edward	1909
Tabor	John Leo	1886
Tabor	Mary	1914
Tabor	Minnie	1918
Tabor	Thomas	1913
Tabor	Trannie Isabell	1910
Tail Feather Woman	Joseph	1884
Tail Feathers	Alice	1902
Tail Feathers	Alice	1906
Tail Feathers	Brocky	1845
Tail Feathers	Charles	1887
Tail Feathers	George	1913
Tail Feathers	Grace	1892
Tail Feathers	James	1886
Tail Feathers	Jennie	
Tail Feathers	John	1911
Tail Feathers	Mary	1873
Tail Feathers	Peter	1891
Tail Feathers	Peter	1867
Tail Feathers	Takes Alone	1893
Tail Feathers	William	1885
Takes Gun Alone	Josephine	1894
Takes Gun Along	Rachel	1880
Takes Gun Both Sides	Joseph	1896
Takes Gun Both Sides	Mollie	1899
Takes Gun Both Sides	Peter	
Takes Gun On Top	Grace	1877
Takes Gun On Top	Johnnie	1894
Takes Gun On Top	Louise	1891
Takes Gun On Top	Maggie	1901
Takes Gun On Top	Maggie	1892
Takes Gun	Agnes	1902
Takes Gun	Cecile	1905
Takes Gun	Kitty	
Takes Gun	Mary	1879
Takes Gun	Minnie	1879
Takes Gun	Rosa	1905
Takes Gun	Rosa	1895
Takes Gun	Star	1900
Takes Gun	Tom	1914
Takes Gun	William	1907
Taking Gun Himself	Joe	1889
Taking Gun	Dick	1888
Tall Eagle Racine	Julia	
Tall Eagle	Mary	1888
Tatsey	Anna	
Tatsey	Annie	1872
Tatsey	David	
Tatsey	Elizabeth	
Tatsey	George	1908
Tatsey	Harriet	1892
Tatsey	Harry	1913
Tatsey	Hattie	1893
Tatsey	Irvin	
Tatsey	Joe	1880
Tatsey	John	1894
Tatsey	Joseph	1864
Tatsey	Kate	1910
Tatsey	Katie	1910
Tatsy	Annie	
Tatsy	Charles	1893
Tatsy	Joe	
Tatsy	Josephine	1889
Tatsy	Susan	1831
Tearing Lodge	Louisa	1889
Tearing Lodge	Louisa	1873
Tearing Lodge	Louise	
Tearing Lodge	Paul	1866
Teasdale	Josephine	1882
Teasdale	Mary	1851
Teasdale	Nellie	1887
Teasdale	Rosa	1880
Teasdale	Rosy	1899
Teasdale	William	1909
Teeth	Josephine	1874
The Bite	Howard	1885
The Bite	Thomas	1891
The Girl	Jimmy	1872
The Ground	James	1877
The Ground	Johnny	1874
The Hoofs	Susan	1865
The Horn	Jakey	1888
The Woman	Gracy	1888
The Woman	Jimmy	1887
Thomas	Addie	1890
Thomas	Addie	1866
Thomas	Annie	1866
Thomas	Charles	
Thomas	Charles	
Thomas	Charles	
Thomas	Charles	
Thomas	Charles	
Thomas	Charles	1878
Thomas	Charles	
Thomas	Charles F.	
Thomas	Charles P.	1874
Thomas	Elsie	1906
Thomas	George	1894
Thomas	Gertrude Katherine	1915
Thomas	Harold	1894
Thomas	Howard	1910
Thomas	Howard	1910
Thomas	Isabel	
Thomas	Isabelle	1845
Thomas	Isabelle Lachier Buck	
Thomas	Jesse Rondin	1913
Thomas	John	1884
Thomas	John	1892
Thomas	John	1881
Thomas	Joseph R.	1911
Thomas	Julia	
Thomas	Julia	
Thomas	Julia	
Thomas	Julia	
Thomas	Julia	1870
Thomas	Mildred	1913
Thomas	Nora	1897
Thomas	Richard	
Thomas	Richard Rondin	
Thomas	Rosa	1888
Thomas	Sarah	1838
Thomas	Susie	1906
Thomas	Susie Rondin	
Thomas	Woodrow Wilson	1912
Thorpe	Fred	
Thorpe	Josephine	1882
Thorpe	Mildred Estella	1913
Thorpe	Russell Albert	1917
Three Bears	Joseph	1895
Three Bulls	Johnny	1877
Three Bulls	Louise	1873
Three Bulls	Rosie	1882
Three Calf	Joe	1916
Three Guns	Agnes	1894
Three Guns	Alice	1895
Three Guns	Annie	1906
Three Guns	Lizzie	
Three Suns	Charles	1818
Timm	Roy	1918
Tingley	Babe	1876
Tingley	Dave	1885
Tingley	John	1872
Tingley	Lizzie	1878
Tingley	Louise	1853
Tingley	Mose	1883
Tingley	Oliver	1874
Tomal	George William	1918
Tomal	Theadora	1916
Top Knot	Rose Lucy M. B.	1909
Tow Guns	Joseph	1896
Trombley	Alfred	
Trombley	Alfred	1906
Trombley	Alfred	1880
Trombley	Cecil	1876
Trombley	Cecile	1911
Trombley	Cecile	1898
Trombley	Cecilia	1911
Trombley	Frank	1902
Trombley	Hester	
Trombley	Isaac	
Trombley	Isaac	
Trombley	Isaac	
Trombley	Isaac	
Trombley	Isaac	1910
Trombley	Isaac	1895
Trombley	Isabel	1830
Trombley	Isabelle	
Trombley	Jennie	1905
Trombley	Joseph	
Trombley	Joseph	
Trombley	Joseph	
Trombley	Joseph	1894
Trombley	Joseph	1869
Trombley	Louie	
Trombley	Louis	1871
Trombley	Maggie	1894
Trombley	Mary	1897
Trowbridge	Mary	
Trudo	Ella	
Trudo	Frank	1884
Trudo	Joseph	1910
Trudo	Lucy	1896
Trudo	Peter	
Trudo	Zonica	
Tucker	Alice	1875
Tucker	Clarence	1898
Turchot	Lenore	1909
Turcotte	Vital	
Turtle	Annie	1904
Turtle	Joe	1900
Turtle	Louis	1903
Turtle	Louis	1907
Turtle	Mary	
Turtle	Mary Ann	1879
Two Guns	Charles	1892
Two Guns	Charlie	1884
Two Guns	John	1884
Two Guns	Mabel	1884
Two Guns	Maggie	1889
Two Guns	Mary	
Two Guns	Mary	1903
Two Guns	Mary	1876
Two Guns	Nancy	1875
Two Guns	Susie	1859
Two Guns	William	1898
Two Spears	Anna	1893
Two Stab	Mabel	1888
Two Stabs	Joe	1892
Two Stabs	Lawrence	1897
Two Stabs	Louis	1895
Two Stabs	Louise	1897
Two Stabs	Mary	
Two Stabs	Thomas	
Two Stabs	Tom	1861
Uhlig	Eliza	1883
Uhlig	Florence	1907
Uhlig	Guy	1916
Uhlig	Harold	1899
Uhlig	Ralph	1905
Uhlig	Robert	1915
Under Bear	Henry	1864
Under Bear	Mary	
Under Bear	Mary	1895
Under Bear	Mary	1861
Under Bear	Mary	1861
Under Bull	Charles	1886
Under Bull	Jack	1891
Under Bull	Jane	1891
Under Bull	Judith	1888
Under Bull	Mary Anne	1893
Under Bull	Peter	1894
Under Mink	Maggie	1907
Under Mink	Mary	
Under Mink	Minnie	
Under Mink	Rosa	1894
Under Mink	Tim	
Under Mouse	Emily	
Under Owl Woman	Baby	1889
Underhill	Harry	1916
Upham	Adeline	1914
Upham	Annie	1871
Upham	Clara	1910
Upham	Clara Livermore	
Upham	Darrell William	1916
Upham	Doctor	1901
Upham	Emma	1864
Upham	Francis	1917
Upham	Hiram	
Upham	Hiram	
Upham	Hiram	
Upham	Hiram	1908
Upham	Hiram	1911
Upham	Hiram	
Upham	Jack	1889
Upham	John	1885
Upham	John Hiram	1918
Upham	Joseph	1883
Upham	Joseph B.	1898
Upham	Kate	1883
Upham	Katherine	1913
Upham	Maggie	1875
Upham	Mary	1891
Upham	Myrtle	
Upham	Myrtle	
Upham	Myrtle	1916
Upham	Myrtle	1887
Upham	Rosa	1880
Upham	Rosie Md. At Holy Fam Mission	1900
Upham	William	
Upham	William	
Upham	William	
Upham	William	
Upham	William	
Upham	William	1861
Upham	Winifred	1899
Upham	Winnefred	
Upham	Winnifred	1917
Vaile	Alvin C.	1917
Vaile	C.E.	
Vaile	Chris	
Vaile	Christopher	
Vaile	Cris	
Vaile	Earl	1917
Vaile	Earl A.	1917
Vaile	Earl Everett	1915
Vaile	Edward	1911
Vaile	Edward	1911
Vaile	Ennis Lawrence	1912
Vaile	George	
Vaile	Hugh	1917
Vaile	Lizzie	1885
Vaile	Mary G.	
Vaile	Mildred	1919
Valleux	Julia	1890
Valleux	Narcise	1890
Valleux	Philhomena	1870
Van Senden	George	1902
Van Senden	John A.	1909
Van Senden	Otto G.	1873
Van Senden	Sauxautha	1909
Vanderpool	Jennie	
Veilleaux	Alimenia	1907
Vernette	Paul	
Vielle	Ann Marie	1918
Vielle	Annie	1892
Vielle	Audrey Benny	1916
Vielle	Ben	1895
Vielle	Carmeleta Frances	1919
Vielle	Cecile	1902
Vielle	Clara	1905
Vielle	Dora	
Vielle	Dora	1897
Vielle	Eliza C.	1908
Vielle	Francis	
Vielle	Francis	
Vielle	Francis	1915
Vielle	Francis	
Vielle	Francis	
Vielle	Francis	1880
Vielle	Francis	1892
Vielle	Frank	1868
Vielle	Frank Jr.	1907
Vielle	Helen Marie	1916
Vielle	Isabel	
Vielle	Isabelle	1904
Vielle	Jack	1889
Vielle	James	
Vielle	John	2
Vielle	John	
Vielle	John	
Vielle	John	
Vielle	John	
Vielle	John	
Vielle	John	
Vielle	John	1866
Vielle	John	1895
Vielle	John	1890
Vielle	Johnny	1868
Vielle	Joseph	1890
Vielle	Josephine	1894
Vielle	Leo	1908
Vielle	Louis	
Vielle	Mabel	1910
Vielle	Maggie	
Vielle	Maria	
Vielle	Marie	
Vielle	Martha Marie	1912
Vielle	Mary	
Vielle	Mary	
Vielle	Mary	
Vielle	Mary	1879
Vielle	Mary	182
Vielle	Nellie	
Vielle	Peter	1893
Vielle	Richard	
Vielle	Sarah	1914
Vielle	Stella May	1915
Vielle	Susan	
Vielle	Thokas	1900
Vielle	Thomas	1877
Vielle	Tom	
Vielle	Vera	1917
Vielle	William	1891
W0lf Plume	Wesley	1885
Wades In Water	Jimmy	1886
Wades In Water	Julia	1888
Wagner	Agnes Norma	1913
Wagner	Anna	1906
Wagner	Annie	
Wagner	Chester	1901
Wagner	Clarence	1909
Wagner	Edna	1908
Wagner	Edna Norman	
Wagner	Fox Annie	1875
Wagner	Garnet	1916
Wagner	Garnet	1918
Wagner	Gertrude	1912
Wagner	Jack	1918
Wagner	Jack	1897
Wagner	Jack	1876
Wagner	John	
Wagner	John W.	1875
Wagner	Joseph	1902
Wagner	Lillie	
Wagner	Mary	1874
Wagner	Nada Croswell	1919
Wagner	Norma Norman	1913
Wagner	Phoebe	1918
Wagner	Vernon	1915
Wagner	William	
Wagner	William	
Wagner	William	
Wagner	William	
Wagner	William	
Wagner	William	
Wagner	William	
Wagner	William	1885
Wagner	William Norman	
Wakes Up Last	Child	
Wakes Up Last	George	1893
Wakes Up Last	Julia	
Wakes Up Last	Mary	1876
Wakes Up Last	Mollie	
Wall	Alfred Lawrence	1902
Wall	Bill	
Wall	I.	1920
Wall	Ida	1898
Wall	Joe	1840
Wall	Joseph	1854
Wall	Juana	1909
Wall	Louise	
Wall	Maggie	1880
Wall	Provincial	1909
Wall	Thomas Francis	1912
Walley	Annie	
Walley	Delema	
Walley	Melvin	
Walter	John	1916
Walter	Mary	1894
Walters	Aaron	
Walters	Aaron	
Walters	Aaron	1912
Walters	Aaron	1874
Walters	Aaron Francis	1912
Walters	Alice	1916
Walters	Alma	1906
Walters	Annie	1914
Walters	Arthur	1910
Walters	Arthur	1907
Walters	Arthur	
Walters	Arthur	
Walters	Arthur	
Walters	Arthur	1900
Walters	Arthur	
Walters	Arthur	1883
Walters	Cora	1913
Walters	Edna	1903
Walters	Elmer	1909
Walters	Frank	
Walters	George	1878
Walters	James	
Walters	James	
Walters	James	1907
Walters	James	1911
Walters	James	1909
Walters	Jessie	1874
Walters	Laura	1914
Walters	Laura	1914
Walters	Lessie	
Walters	Lincoln	1902
Walters	Louise	
Walters	Mary Prairie Chicken	1915
Walters	Minnie	
Walters	Robert	1900
Walters	Sylvan	1905
Walters	Ursula	1918
War Bonnet	Anna	1833
War Bonnet	Annie	1905
War Bonnet	Charles	1886
War Bonnet	Dick	1901
War Bonnet	James	1895
War Bonnet	Jennie	1892
War Bonnet	Lucy	1908
War Bonnet	Thomas	1916
Ward	George	1892
Ward	James	1891
Ward	Mary Rose	1895
Ward	Rosa	1868
Way Laid Woman	Maggie	1883
Weasel Head	Anna	1885
Weasel Head	Billy	1890
Weasel Head	Charles	1911
Weasel Head	George	1905
Weasel Head	Isaac	1874
Weasel Head	Jennie	1919
Weasel Head	John	1894
Weasel Head	John	1887
Weasel Head	Joseph	1886
Weasel Head	Lucy	1910
Weasel Head	Lucy	1893
Weasel Head	Maggie	1881
Weasel Head	Margaret	1913
Weasel Head	Mary	
Weasel Head	Mary	
Weasel Head	Mary	
Weasel Head	Mary	
Weasel Head	Mary	1916
Weasel Head	Mary	1907
Weasel Head	Mary	1881
Weasel Head	Mary	
Weasel Head	Mary	1844
Weasel Head	Mary	1875
Weasel Head	Minnie	
Weasel Head	Mollie	1872
Weasel Head	Patrick	1915
Weasel Head	Peter	1888
Weasel Head	Rosa	1893
Weasel Head	Sallie	1892
Weasel Head	Thomas	1896
Weasel Horn	Little Girl	1840
Weasel Tail	Annie	1884
Weasel Tail	Antoine	1895
Weasel Tail	Emma	
Weasel Tail	James	
Weasel Tail	James	1922
Weasel Tail	James	
Weasel Tail	John	
Weasel Tail	Louise	1893
Weasel Tail	Maggie	1882
Weasel Woman	Cecile	1908
Weasel Woman	James	1906
Weather Wax	Baby	1886
Weather Wax	Cecile	1913
Weather Wax	Enla Agnes	1915
Weather Wax	J. D.	
Weather Wax	J.D.	
Weather Wax	Joseph	1885
Weather Wax	Maggie Littel Dog	
Weather Wax	Maggie Little Dog	
Weed	Tobacco N.	
Weipert	Mary Ann	1879
Welch	Alice	1887
Welch	Alice Hagan	
Welch	Angeline	
Welch	Betty	1916
Welch	Charles Blythe	1911
Welch	Clarence	1899
Welch	Cora L.	
Welch	Daniel	1906
Welch	Daniel Stewart	1911
Welch	Ellen	1882
Welch	Evla Agnes	1917
Welch	Helen	1912
Welch	James	
Welch	James B.	1905
Welch	James B. Non Indian	
Welch	James Philip	1914
Welch	James Phillip Jr.	1911
Welch	James William	1912
Welch	John Lea	1915
Welch	L. R.	
Welch	L.R.	
Welch	William	
Wells	Albert	
Wells	Angeline	1918
Wells	David	1905
Wells	Helen	1884
Wells	Jennie	
Wells	Jennie	
Wells	Jennie	
Wells	Jennie	1903
Wells	Jennie	
Wells	Jennie	1916
Wells	Jennie	1886
Wells	Jennie Running Antelope Gambler	1903
Wells	Joseph	1915
Wells	Lilly	1906
Wells	Maggie	
Wells	Philip	
Wells	Sarah	1911
Wells	William	1913
West Wolf	Annie	1884
West Wolf	Arthur	1893
West Wolf	Baptist	
West Wolf	Baptiste	1878
West Wolf	Bernard	1885
West Wolf	Clarence	1883
West Wolf	Clement	1882
West Wolf	Eugene	1890
West Wolf	George	1878
West Wolf	John	1892
West Wolf	John	1891
West Wolf	Mabel	1913
West Wolf	Mary	1902
West Wolf	Mike	1918
West Wolf	Paul	1891
West Wolf	Philip	1911
West Wolf	Robert	1916
West Wolf	Robert	1880
Wetzel	Daisy	1879
Wetzel	Donald Wright	1914
Wetzel	Henrietta	
Wetzel	Henrietta V.	1887
Wetzel	Joseph	1909
Wetzel	Joseph Jesse Burd	1912
Wetzel	Maggie	
Wetzel	Pearl	1877
Wetzel	Walter Scott	1915
Wetzel	William	
Wetzel	William S.	
Wetzel	Willie	1881
Whistler	Isaac	
Whitcomb	Maisie	1922
White Antelope	Charles	1877
White Antelope	James	1890
White Antelope	Joseph	
White Antelope	Mary	1894
White Antelope	Molly	1879
White Calf	Agnes	1904
White Calf	Annie	1887
White Calf	Annie	1887
White Calf	Blanch	1906
White Calf	Blanche	1889
White Calf	Camas	1884
White Calf	Child	
White Calf	James	1865
White Calf	James Jr.	1915
White Calf	Jim	
White Calf	Jimmy	1866
White Calf	John	
White Calf	John	
White Calf	John	
White Calf	John	
White Calf	John	
White Calf	John	
White Calf	John	1872
White Calf	John	1886
White Calf	John	1859
White Calf	Josephine	1909
White Calf	Josephine	1892
White Calf	Julia	1900
White Calf	Mabel	1888
White Calf	Maggie	
White Calf	Mamie	1888
White Calf	Mary	
White Calf	Mary	
White Calf	Mary	1880
White Calf	Mary	1898
White Calf	Mary	1865
White Calf	Mary	1870
White Calf	Minnie	
White Calf	Minnie	
White Calf	Minnie	1867
White Calf	Minnie	1871
White Calf	Rose	1884
White Calf	Susan	1907
White Calf	Tom	1895
White Calf	William	1902
White Dog	Anna	1886
White Dog	Annie	1894
White Dog	Frank	1890
White Dog	George	1900
White Dog	Henry	1895
White Dog	Josephine	1902
White Dog	Rosa	1893
White Dog	William	
White Grass	Allyn	1919
White Grass	Angeline	1879
White Grass	Angelique	1900
White Grass	Elizabeth	1899
White Grass	Eoss	
White Grass	Isabel	
White Grass	Isabell	1899
White Grass	James	1909
White Grass	Joe	
White Grass	John	1911
White Grass	Joseph	
White Grass	Josephine	1911
White Grass	Katie	1869
White Grass	Mary	1914
White Grass	Minnie	1871
White Grass	Nels	1893
White Grass	Paul	1891
White Grass	Richard W.	1897
White Grass	Ross	1877
White Grass	Shorty	
White Grass	Steve	1913
White Grass	Susan	1892
White Horse	Garrett	1874
White Man	Adam	1907
White Man	Agnes	1903
White Man	Annie	1879
White Man	Billy	1881
White Man	Hannah	
White Man	James	1890
White Man	John	1882
White Man	Mae	1892
White Man	Mary	
White Man	Minnie	1899
White Man	Paul	1907
White Man	Peter	
White Man	Peter	
White Man	Peter	
White Man	Peter	1878
White Man	Peter	1920
White Man	Richard	1902
White Man	Richard	1905
White Man	Susan	
White Man	William	1919
White Petrified	Buffalo Rock	
White Quiver	Benjamin	1884
White Quiver	Josephine	1896
White Quiver	Maggie	1891
White Quiver	Thomas	1895
White Swan	Charles	1875
White Swan	Julia Thomas	1902
White Swan	Minnie	
White	Agnes	1915
White	Albert	1914
White	Almira	
White	Alonzo	1871
White	Aveline	1911
White	Barbara	
White	Charles	1888
White	Cora	1892
White	Florence Mildred	1914
White	Garrett	1873
White	Garrett Eli	1908
White	Genevive	1906
White	Isaac	
White	Jerome M.	1916
White	John	1888
White	Lorenzo	
White	Lou	1893
White	Malvina	1896
White	Mary	
White	Mary Jane	1876
White	Mary Rose	1905
White	Melvina	
White	Mildred May	1918
White	Nanch Renville	1863
White	Nancy Renville	
White	Rosa	1882
White	Vernie	1901
Whiteman	Susan	
Whitford	Agnes	1917
Whitford	Andrea Thomas	1916
Whitford	Elizabeth	1884
Whitford	Elizabeth	1854
Whitford	Harry	1915
Whitford	Lily	
Whitford	Lizzie	
Whitford	Loretta Marie	1919
Whitford	Magnus	
Whitford	Peter	1908
Wicked Woman	George	1887
Widow By Jul1910/ Sellen	William R.	1879
Wilcox	Louise	1893
Wild Gun	Annie	1895
Wild Gun	John W.	1880
Wild Gun	Joseph	1919
Wild Gun	Julia	
Wild Gun	Richard	1915
Wild Gun	Rose	1897
Willard	John	
Willard	Telicia	1884
Willard	Tilicia	1907
Willard	Victoria	
Williams	James	
Williams	Minnie	1888
Williamson	Billy	1884
Williamson	Elenor May	1915
Williamson	Elmer	1878
Williamson	Gertrude	1887
Williamson	Guy	1904
Williamson	Harvey	1900
Williamson	Henry	1882
Williamson	Henry Dewey	1918
Williamson	Henry Rockford	1881
Williamson	Irene	1918
Williamson	James	1891
Williamson	James Thomas	1919
Williamson	Maggie	1885
Williamson	Mary	1885
Williamson	Mildred	1905
Williamson	Murray Lee	1917
Williamson	Parker	1902
Williamson	Ruby Vera	1911
Williamson	Susan	1863
Williamson	Thomas	1908
Williamson	Thomas E.	
Williamson	Thomas Richard	1919
Williamson	Tim	
Wind Blowing The Trees	Annie	1876
Wipert	Alloysuis	1912
Wipert	George	1908
Wipert	Isaac	1872
Wipert	Maggie	
Wipes His Eyes	Child	
Wipes His Eyes	Joseph	1897
Wipes His Eyes	Maggie	1897
Wipes His Eyes	Maggie	1907
Wipes His Eyes	Mollie	1902
Wipes His Eyes	Susie	1891
Wippert	Aloysius	1913
Wippert	Frank William	1919
Wippert	George	1908
Wippert	Isaac	
Wippert	Isaac Hunter	1916
Wippert	John	1905
Wippert	Mary	1881
Wolf Chief	George	1897
Wolf Chief	Irene	1903
Wolf Chief	Isabel	
Wolf Chief	Joseph	1902
Wolf Chief	Maggie	1882
Wolf Chief	Mary	1862
Wolf Chief	Mollie	1897
Wolf Eagle	George	1895
Wolf Eagle	Maggie	
Wolf Eagle	Mary	1887
Wolf Moccasin	Joseph	1892
Wolf Plume	Cecile	1908
Wolf Plume	Frank	1892
Wolf Plume	George	1894
Wolf Plume	Louise	1871
Wolf Plume	Mary	1893
Wolf Plume	Wesley	1887
Wolf Tail	Agnes	1905
Wolf Tail	Angeline	1903
Wolf Tail	Cecile	1890
Wolf Tail	Charles	1918
Wolf Tail	Corrall	1885
Wolf Tail	Florence	1917
Wolf Tail	George	1905
Wolf Tail	Gilbert	1886
Wolf Tail	John	1894
Wolf Tail	Joseph	1897
Wolf Tail	Julia	
Wolf Tail	Julia	1907
Wolf Tail	Julia	1889
Wolf Tail	Julia	1885
Wolf Tail	Kate	
Wolf Tail	Katie	
Wolf Tail	Minnie	1889
Wolf Tail	Phoebe	1894
Wolf Tail	Thomas	1896
Wolf Woman	Big Road	
Wolverine	Amy Mary	1910
Wolverine	George	1895
Wolverine	Jack	1898
Wolverine	James	1905
Wolverine	John	1907
Wolverine	Joseph	1895
Wolverine	Martha	
Wolverine	Mary	
Wolverine	Mary	
Wolverine	Mary	1919
Wolverine	Mary	1893
Wolverine	Mary	1822
Wolverine	Vinnie	1915
Wolverine	Virnnie	1893
Wolverine	William	
Woman Change	Charley	1886
Woman Change	Fred	1887
Woman Change	Harry	1875
Woman Change	Louise	1853
Woman Change	Nancy	1877
Woman Change	Sarah	1886
Wood Woman	Mary Ann	1891
Wood	Lucy	1878
Woodbury	Clifton Rosin	1915
Woodbury	Dora	
Woodbury	Stanley	
Woods	Mary	1915
Woodward	Guy Eric	1914
Woodward	Rosa	1905
Woodward	Rose	1888
Worth	Mrs.	1915
Wren	Cathrine	1879
Wren	Celena	
Wren	Dora	1887
Wren	Elizabeth	1877
Wren	Ellen	1875
Wren	Elsie	1912
Wren	George	1869
Wren	Georgia	1911
Wren	Ida	1893
Wren	Irvin	1912
Wren	Isabele	
Wren	Isabell	
Wren	James Jefferson	1907
Wren	John	
Wren	John	
Wren	John	
Wren	John	
Wren	John	
Wren	John	
Wren	John	1882
Wren	John S.	
Wren	Julia	1894
Wren	Lillie	1892
Wren	Mary Jane	1908
Wren	Mary Jane	1874
Wren	Melinda	1849
Wren	Mrs. George	
Wren	Pauline	1916
Wren	Robert	1885
Wren	Salina	1901
Wren	Samuel George	1915
Wren	Susan	1869
Wren	William	1890
Wright	Angeline-Gobert-Barlow Percival	
Wright	Donald William	
Wright	Edward	1889
Wright	Ida Rose	1913
Wright	John	1888
Wright	John A.	1912
Wright	John M.	
Wright	Josephine May	1915
Wright	Mollie	1872
Wright	Mrs. William	
Wright	Rose	
Wright	Sallie	1874
Wright	William	
Wright	William	
Wright	William	
Wright	William	1887
Wright	William Howard	1916
Wright	William Howard	1916
Yellow Bird	Louise	
Yellow Eyed	Mary	1867
Yellow Iron	Annie	1893
Yellow Kidney	Helen	
Yellow Kidney	Maggie	
Yellow Kidney	Michael	
Yellow Kidney	Mike	1892
Yellow Kidney	Rosie	1895
Yellow Owl	Child	
Yellow Owl	James	1895
Yellow Owl	James	
Yellow Owl	Lucy	1898
Yellow Owl	Margaret	
Yellow Owl	Margaret	
Yellow Owl	Margaret	
Yellow Owl	Margaret	
Yellow Owl	Margaret	
Yellow Owl	Margaret	1875
Yellow Owl	Margaret	
Yellow Owl	Nancy	1902
Yellow Owl	Peter	
Yellow Owl	Peter Jr.	1911
Yellow Owl	Rosie	1915
Yellow Owl	Susie	1904
Yellow Snake	Frank	1888
Yellow Snake	Jimmy	1886
Yellow Snake	Sadie	1882
Yellow Spider Woman	Elizabeth	1891
Yellow Spring	Alice Rosa	1908
Yellow Springs	Alice Rosa	
Yellow Wolf	Agnes	1886
Yellow Wolf	Arthur	1909
Yellow Wolf	Boyce	1896
Yellow Wolf	Cecile	
Yellow Wolf	Cecile Sanderville	
Yellow Wolf	Child	
Yellow Wolf	Cicell	1870
Yellow Wolf	Emma	1917
Yellow Wolf	Emma	1898
Yellow Wolf	Emma	1867
Yellow Wolf	Evla	1902
Yellow Wolf	Joseph	1904
Yellow Wolf	Julia	
Yellow Wolf	Kate	1898
Yellow Wolf	Mary	
Yellow Wolf	Mary	1906
Yellow Wolf	Mary	1910
Yellow Wolf	Mary J.	1873
Yellow Wolf	Mildred	1887
Yellow Wolf	Minnie	1904
Yellow Wolf	Mollie	1892
Yellow Wolf	Rony	1893
Yellow Wolf	Sam	1865
Yellow Wolf	Susan	1892
Yells In The Water	George	
Yells In Water	John	1892
Young Bear Chief	Bill	1885
Young Bear Chief	George	1894
Young Bear Chief	Louisa	1887
Young Bear Chief	Madeline	1888
Young Bear Chief	Mary	1889
Young Bear Chief	Mary	1888
Young Bear Chief	Pressly	
Young Bear Chief	Sebastion	1895
Young Eagle	James	1887
Young Eagle	Joseph	
Young Eagle	Joseph Jr.	1902
Young Eagle	Nicholas	
Young Man Chief	Cecile	1870
Young Man Chief	Child	
Young Man Chief	George	1894
Young Man Chief	Isabella	1908
Young Man Chief	Jennie	1888
Young Man Chief	Johnnie	1910
Young Man Chief	Louise	1891
Young Man Chief	Morgan	1896
Young Running Crane	Dick	1889
Young Running Crane	Isabel	
Young Running Crane	Isabelle	
Young Running Crane	John	
Young Running Crane	Samuel	1910
Young Running Crane	Susan	1911
Young Running Crane	Willie	1913
Young Running Rabbit	Charles	1894
Young Running Rabbit	Esther	1884
Young Running Rabbit	Isabelle	1890
Zeigler	George	1917

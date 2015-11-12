#programa para parsear un archivo uniprot y extrar toda la información en forma de tabla

use strict;

my $IDUniprot;
my $StatusUniprot;
my $SequenceLenghtUniprot;
my $ACUniprot;#always the first como dice en la pagina
my $ACSaved=0;
my $DateUniprotFirst;
my $DateUniprotLast;
my $FirstDateSaved=0;
my $RecNameUniprot;
my $RecNameSaved=0;
my @IncludesUniprot;
my @ContainsUniprot;
my $AltNameUniprot;
my $AltNameSaved=0;
my @NameGeneUniprot;
my @SynonymsNameUniprot;
my @ORFNamesUniprot;
my $OrganismoUniprot;
my @ClasificacionUniprot;
my $NCBITaxIDUniprot;
my @NCBIHostTaxIDUniprot;
my @NCBIHostName;
my @CitationUniprot;
my @TypeCitation;
my @WhereCitation;
my $RevistaUniprot;
my @RevistaUniprot;
my @ComentsUnipro;
my $ComentsUniprotSaved=0;
my @OtherDatabasesUniProt;
my $ProteinEvidenceUniprot;
my $SEQUENCERead=0;
my @SequenceUniprot;
my @AnotationUniprot;
my @PositionsAnotationUniprotInicio;
my @PositionsAnotationUniprotFin;


my $NombreArchivoUniprot=shift;
open (ENTRADA,$NombreArchivoUniprot);
my @LecturaArchivo=<ENTRADA>;
close ENTRADA;

for (my $i=0;$i<scalar@LecturaArchivo;$i++){
  my $DosLetrasUniprot=substr(@LecturaArchivo[$i],0,2);
  my $LineaActual=@LecturaArchivo[$i];
  #print "\n-$DosLetrasUniprot-";
  if ($DosLetrasUniprot eq "ID"){#solo es una linea
    $LineaActual=~/ID\s+([A-Z0-9]+_[A-Z0-9]+)\s+([A-Za-z]+);\s+([0-9]+)\s/;#ID\t+([A-Z0-9]+_[A-Z0-9]+)\t
    #print "----$1----$2------$3";
    $IDUniprot=$1;
    $StatusUniprot=$2;
    $SequenceLenghtUniprot=$3;
    print "\nID_Uniprot: $IDUniprot\nEstado_Uniprot: $StatusUniprot\nSequence Length=$SequenceLenghtUniprot";
  }
  if ($DosLetrasUniprot eq "AC"){
    if ($ACSaved==0){
      $LineaActual=~/AC\s+([OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2})/;
      $ACUniprot=$1;
      print "\nMost Recent Accession number: $ACUniprot";
      $ACSaved=1;
    }
  }
  if ($DosLetrasUniprot eq "DT"){
    $LineaActual=~/DT\s+([0-9]{2}-[A-Z]{3}-[0-9]{4}),/;
    #print "\n---$1---";
    if ($FirstDateSaved==0){
      $DateUniprotFirst=$1;
      $FirstDateSaved=1;
      print "\nFirst date:$DateUniprotFirst";
    }
    if (substr(@LecturaArchivo[$i+1],0,2)ne "DT"){
      $DateUniprotLast=$1;
      print"\nLast date: $DateUniprotLast";
    }
  }
  if ($DosLetrasUniprot eq "DE"){
    if($LineaActual=~/DE\s+RecName:\s+Full=(.*);/ && $RecNameSaved==0){
      $RecNameUniprot=$1;
      $RecNameSaved=1;
      print"\nRecomended Name is: $RecNameUniprot";
    }
    if($LineaActual=~/DE\s+AltName:\s+Full=(.*);/ && $AltNameSaved==0){
      $AltNameUniprot=$1;
      $AltNameSaved=1;
      print "\nAlternative names is: $AltNameUniprot";
    }
    if ($LineaActual=~/DE\s+Contains:/){
      @LecturaArchivo[$i+1]=~/DE\s+RecName:\s+Full=(.*);/;
      push (@ContainsUniprot,$1);
      print "\nContains: $1";
    }
    if ($LineaActual=~/DE\s+Includes:/){
      @LecturaArchivo[$i+1]=~/DE\s+RecName:\s+Full=(.*);/;
      push (@IncludesUniprot,$1);
      print "\nIncludes: $1";
    }
  }
  if ($DosLetrasUniprot eq "GN"){#revisar
    $LineaActual=~/GN\s+Name=(\w+);\s+Synonyms=(\w+)/;
    my $ComprobarORF=$1;
    if ($1 ne ""){
      push (@NameGeneUniprot,$1);
      print"\nGene name(Uniprot): $1\nSynonimous name(Uniprot): $2";
      push (@SynonymsNameUniprot,$2);
    }
    $LineaActual=~/ORFNames=(\w+);/;
    if ($ComprobarORF ne $1){
      push (@ORFNamesUniprot,$1);
      print "\nORF Name: $1";
    }
  }
  if ($DosLetrasUniprot eq "OS"){
    $LineaActual=~/OS\s+(.*)./;
    $OrganismoUniprot=$1;
    print "\nOrganimso: $OrganismoUniprot";
  }
  if ($DosLetrasUniprot eq "OC"){
    $LineaActual=~/OC\s+(.*)\n/;
    my $AddToClasification=$1;
    my @AddToClasification=split("; ",$AddToClasification);
    for (my $j=0;$j<scalar@AddToClasification;$j++){
      push(@ClasificacionUniprot,@AddToClasification[$j]);
      print "\nClasification of organism: @AddToClasification[$j]";
    }
  }
  if ($DosLetrasUniprot eq "OX"){
    $LineaActual=~/OX\s+NCBI_TaxID=([0-9]+);/;
    my $NCBITaxIDUniprot=$1;
    print "\nTax ID of Uniprot:$NCBITaxIDUniprot";
  }
  if ($DosLetrasUniprot eq "OH"){
    $LineaActual=~/OH\s+NCBI_TaxID=([0-9]+);\s+(.*)./;
    push(@NCBIHostTaxIDUniprot,$1);
    push(@NCBIHostName,$2);
    print "\nPathogen! Host Tax ID of uniprot:$1, NCBI host name: $2";
  }
  if ($DosLetrasUniprot eq "RN"){
    $LineaActual=~/RN\s+\[(\d)\]/;
    my $CitationUniprot=$1;
    push (@CitationUniprot,$CitationUniprot);
    print "\n\nNumber of cite: $CitationUniprot";
  }
  if ($DosLetrasUniprot eq "RP"){
    $LineaActual=~/RP\s+(.*)/;
    my $TypeCitation=$1;
    push (@TypeCitation,$TypeCitation);
    print "\nType of cite: $TypeCitation";
  }
  if ($DosLetrasUniprot eq "RX"){
    $LineaActual=~/RX\s+(.*)/;
    my $WhereCitation=$1;
    push (@WhereCitation,$WhereCitation);
    if ($WhereCitation ne ""){print "\nCited in: $WhereCitation"};
  }
  if ($DosLetrasUniprot eq "RL"){
    $LineaActual=~/RL\s+(.*)/;
    $RevistaUniprot=$1;
    push(@RevistaUniprot,$RevistaUniprot);
    if ($RevistaUniprot ne ""){print "\nCited in Uniprot: $RevistaUniprot";}
  }
  if ($DosLetrasUniprot eq "CC" && $ComentsUniprotSaved==0){
    $LineaActual=~/CC\s+(.*)/;
    if ($ComentsUniprotSaved==0){
      my $ComentsUnipro=$1;
      #print $ComentsUnipro;
      if ($LineaActual=~/CC\s+--------/){
        print "\n\n";
        $ComentsUniprotSaved=1;
      }
      else{
      push (@ComentsUnipro,$ComentsUnipro);
      print "$ComentsUnipro";
      }
    }
    #print "@ComentsUnipro";
  }
  if ($DosLetrasUniprot eq "DR"){
    $LineaActual=~/DR\s+(\w+);\s+(.*);/;
    my $OtherDatabasesUniProt=$1;
    my $NameInOtherDatabase=$2;
    my $AltNameInOtherDataBase=$3;
    push (@OtherDatabasesUniProt,$OtherDatabasesUniProt);
    print "\nOther databases: $OtherDatabasesUniProt";
    print "     Name: $NameInOtherDatabase";
  }
  if ($DosLetrasUniprot eq "PE"){
    $LineaActual=~/PE\s+(\d)/;
    $ProteinEvidenceUniprot=$1;
    print "\nProtein evidence in uniprot score: $ProteinEvidenceUniprot";
  }
  if ($DosLetrasUniprot eq "SQ"){
    if($LineaActual=~/SQ\s+SEQUENCE\s/){
      $SEQUENCERead=1;
    }
  }
  if ($SEQUENCERead==1 && $LineaActual=~/\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)/){
    $LineaActual=~/\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)/;
    #substr($1,$2,$3,$4,$5,$6,0,1);
    push (@SequenceUniprot,$1,$2,$3,$4,$5,$6);
  }
  if ($DosLetrasUniprot eq "FT"){#anotacion
    if($LineaActual=~/FT\s+(\w+)\s+(\w+)\s+(\w+)\s+/){
      print "\nAnotation: ";
      push (@AnotationUniprot,$1);
      push(@PositionsAnotationUniprotInicio,$2);
      push(@PositionsAnotationUniprotFin,$3);
      print "$1----$2---$3";
    }
  }
}
    print "\nSecuence:\n@SequenceUniprot";



#rrrrrrrrrrrrrrr


#DR,KW(key words), pasar a archivo con todo bonito

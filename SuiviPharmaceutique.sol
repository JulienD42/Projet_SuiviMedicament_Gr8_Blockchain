//Version du compilateur 
pragma solidity ^0.4.24;

//import des fichiers .sol en tant que librairie liée au contrat (dont la liste blanche)
import "./Ownable.sol";
import "./WhitelistedRole.sol";

//Création du contrat avec intégration des librairies 
contract SuiviMedicament is Ownable, WhitelistedRole{
    
    //Création de la structure médicament pour y rattracher toute les informations du médicament
    struct medicament {
        
        //Informations principales de la structure : nom, ID et si le médicament a été créé 
        uint IDMedicament;
        bool infomedgenerees;
        string nameMedicament;

        // Informations secondaire : Nombre de lots de ce médicament, nombre médicament par lots, ID du lot et date de sortie du médicament 
        uint NbLots;
        uint NbPdtLot;
        uint IDLot; 
        uint dateProd;

        // Variables partie livraison : Statut : texte renvoyé pour le changement d'état et variable d'etat : définit de manière numérique l'état de livraison
        string statutLivraison;
        uint orderstatus; // 1 = commandé, 2 = en cours de livraison, 3 = livré, 4 commande annulée
        
        // Données d'usine : date de sortie d'usine et destination du médicament 
        uint DatedeSortie;
        address destination;
        
        // Données du premier checkpoint : le centre de distribution : adresse et heure de passage
        address AdrCentre;
        uint heureCentre;
        
        // Données du deuxieme checkpoint : la distribution locale : adresse et heure de passage
        address AdrDistribution;
        uint heureDistribution;
        
        // Données du dernier checkpoint : la pharmacie : adresse et heure d'arrivée
        address AdrPharmacie;
        uint heureArrivee;
        
    }
    
    //Mapping afin de pouvoir différencier les informations de chaque médicament (exemple : paracétamol et lexomyl)
    mapping (address => medicament) medicamentmapping;
    mapping (address => bool) public Checkpoint;
    
    constructor(){
        
        owner = msg.sender;
        
    }
    
    // Création de la fonction Only Owner à utiliser dans différentes fonctions afin de sécuriser la modifition d'informations
    modifier onlyOwner(){
        
        //require(owner == msg.sender);
        require(isWhitelisted(owner));
        _;
        
    }
    
    // Vérification que le checkpoint est le bon 
    function MananageCheckpoints(address _addressCheckpoint) onlyOwner public  returns (string){
        
        if(!Checkpoint[_addressCheckpoint]){
            
            Checkpoint[_addressCheckpoint] = true;
            
        }else {
            
            Checkpoint[_addressCheckpoint]=false;
            
        }
        
        return "Statut Checkpoint mis à jour";
        
    }
    
    // Fonction pour le transfert de propriété du contract
    function transertOwners(address nouveauowner) public onlyOwner{
        
        transferOwnership(nouveauowner);
        
    }
    
    // Fonction pour créer un nouveau médicament avec ses informations (cf structure)
    function PasserCommande(uint _IDMedicament, string _nameMedicament, uint _NbLots, uint _IDLot, uint _dateProd) public returns(address){
        
        address IDUnique = address(sha256(msg.sender, now));
        
        medicamentmapping[IDUnique].infomedgenerees = true;
        medicamentmapping[IDUnique].IDMedicament = _IDMedicament;
        medicamentmapping[IDUnique].nameMedicament = _nameMedicament;
        medicamentmapping[IDUnique].NbLots = _NbLots;
        medicamentmapping[IDUnique].IDLot = _IDLot; 
        medicamentmapping[IDUnique].NbPdtLot = 10;
        medicamentmapping[IDUnique].dateProd = _dateProd;
        medicamentmapping[IDUnique].statutLivraison = "Medicament en cours de preparation";
        medicamentmapping[IDUnique].orderstatus = 1;
        
        medicamentmapping[IDUnique].destination = msg.sender;
        medicamentmapping[IDUnique].DatedeSortie = now;
        
        return IDUnique;
        
    }
    
    // Fonction pour annuel la commande (lorsqu'elle est en cours de livraison) avec sécurisation de l'accès à l'annulation
    function AnnulerCommande(address _IDUnique) public returns (string){
        
        require(medicamentmapping[_IDUnique].infomedgenerees);
        require(isWhitelisted(medicamentmapping[_IDUnique].destination));
        
        medicamentmapping[_IDUnique].statutLivraison = "Votre commande a été annulé";
        medicamentmapping[_IDUnique].orderstatus = 4;
        
        return "Votre commande a bien été annulée";
        
        
    }
    
    // Fonction pour reporter la bonne arrivée (avec l'heure d'arrivée) du médicament au centre de distribution
    function ReportCentreDeDistribution(address _IDUnique, string _statutLivraison){
        
        require(medicamentmapping[_IDUnique].infomedgenerees);
        require(Checkpoint[msg.sender]);
        require(medicamentmapping[_IDUnique].orderstatus == 1);
        
        medicamentmapping[_IDUnique].statutLivraison = _statutLivraison;
        medicamentmapping[_IDUnique].AdrCentre = msg.sender;
        medicamentmapping[_IDUnique].heureCentre = now;
        medicamentmapping[_IDUnique].orderstatus = 2;
        
    }
    
    // Fonction pour reporter la bonne arrivée (avec l'heure d'arrivée) du médicament à la distribution locale
    function ReportDistributionLocale(address _IDUnique, string _statutLivraison){
        
        require(medicamentmapping[_IDUnique].infomedgenerees);
        require(Checkpoint[msg.sender]);
        require(medicamentmapping[_IDUnique].orderstatus == 1);
        
        medicamentmapping[_IDUnique].statutLivraison = _statutLivraison;
        medicamentmapping[_IDUnique].AdrDistribution = msg.sender;
        medicamentmapping[_IDUnique].heureDistribution = now;

    }
    
    // Fonction pour reporter la bonne arrivée (avec l'heure d'arrivée) du médicament à la pharmacie
    function ReportPharmacie(address _IDUnique, string _statutLivraison){
        
        require(medicamentmapping[_IDUnique].infomedgenerees);
        require(Checkpoint[msg.sender]);
        require(medicamentmapping[_IDUnique].orderstatus == 1);
        
        medicamentmapping[_IDUnique].statutLivraison = _statutLivraison;
        medicamentmapping[_IDUnique].AdrPharmacie = msg.sender;
        medicamentmapping[_IDUnique].heureArrivee = now;
        medicamentmapping[_IDUnique].orderstatus = 3;
        
        
    }
    
    
}
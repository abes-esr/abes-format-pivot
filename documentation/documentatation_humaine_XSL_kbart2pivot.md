
# Documentation humaine de l’XSLT kbart2pivot


## Le format KBART

Les fichiers KBART sont des fichiers tabulés qui répondent à une recommandation NISO (https://www.niso.org/standards-committees/kbart) et permettent d’échanger des métadonnées sur les contenus de bases de données entre les diffuseurs (plate-formes d’éditeurs ou agrégateurs), les bibliothèques et les fournisseurs de bases de connaissances. Les intitulés des 25 colonnes sont fixes mais certaines données sont optionnelles.

Les fichiers KBART décrivent soit des ensembles de revues, soit des ensembles de livres électroniques. Les métadonnées sont fines sur les états de collection (possible de détailler jusqu’au numéro) et les types d’accès (payant, libre, plein-texte ou résumé). Le KBART est le seul format natif à ne pas utiliser les autorités. On ne récupère que des mentions de contributeurs (first_author , first_editor, publisher_name).


## Conversion et nommage

Les fichiers initiaux en tabulé ont d’abord été convertis en XML au moyen d’OpenRefine. Chaque balise <ligne> englobe toutes les informations d’une ligne du tableau (comme la balise <wemi> englobe toutes les informations tirées d’une notice MARC.)

A la racine, on va construire un ID du bouquet qui va être réutilisé pour forger les ID de toutes les entités du bouquet. Cet ID normalisé comme par la racine http://www.abes.fr/kbart/ suivi du nom du bouquet qui désigne le corpus en utilisant le nom de l’éditeur. On crée une entité de type ENSEMBLE et BOUQUET.

L’exploitation d’une ontologie en RDF déclarant que Bouquet est une sous-classe de Ensemble peut permettre d’omettre le type Ensemble en sortie (dans un XSLT de chargement Pivot2RDF)

On pourrait utiliser cette entité pour faire porter des informations de dates, afin de distinguer plusieurs versions ou mises à jour d’un même bouquet (non réalisé dans les PoC.)


## Une adaptation du tronc OEMI

Chaque ligne a un identifiant constitué de l’ID bouquet auquel on rajoute une variable qu’on va chercher au sein de la ligne : online_identifier, ou si l’information fait défaut, dans print_identifier (l’ISSN ou l’ISBN). La colonne publication_type permet de renseigner la variable typeDoc (MONOGRAPHIE ou PUBSERIE).

Chaque ligne donne lieu à la création d’une instance d’entité oeuvre, d’une ou deux manifestations et d’un item.

On ne crée pas d’entité de type “expression” tel que IFLA-LRM le prévoit car on n’avait aucune information à faire porter par ce niveau (le KBART ne donne par exemple aucune information de langue). Par ailleurs, générer des troncs “O-M-I” et des relations A_POUR_MANIFESTATION_SS_E était un moyen de tester la coexistence des deux modèles dans un même système, puisque les informations issues des autres formats(MARC, TEF, RDF) donnent elles lieu à la création d’entités de type expressions.

Une ligne peut donner lieu à la création de deux entités manifestations car on exploite le print_identifier qui décrit non pas la ressource qui fait partie du bouquet, mais qui décrit une relation entre la ressource et son équivalent sur un autre support.

La manifestation électronique est liée à un et un seul Item qui porte les informations relatives à l’accès : d’état de collection, URL et type d’accès.

Tous les Items issus de chacunes des lignes d’un fichier KBART ont une relation EST_AGREGE_DANS avec l’entité Bouquet.

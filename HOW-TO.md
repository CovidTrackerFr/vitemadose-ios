# FAQ

## Mettre en place un serveur local pour jouer avec des données

Pour tester l'application ainsi que les évolutions et corrections faites dessus, il est possible d'utiliser un serveur web HTTP en local pour remplacer le serveur de production.
Quelques étapes ci-dessous :

### Configuration

1. Installer un serveur web HTTP sur une machine
2. Récupérer l'adresse IP locale de cette machine, admettons ici **w.x.y.z**
3. Dans le fichier _remote-configuration.plist_, remplacer la valeur associée à la clé **url_base** par **http://w.x.y.z**. Il faudra aussi certainement renseigner le port sur lequel tourne le serveur (par exemple **8888**)
4. Dans le dossier web pour ce serveur, placer un fichier _index.html_ avec par exemple le code ci-dessous:
```HTML
<!doctype html>
<html lang="fr">
    <head>
        <title>Vite Ma Dose (localhost)</title>
    </head>
    <body>
        <h1>Youpi !</h1>
    </body>
</html>
```
5. Via un navigateur web, saisir l'URL du site web, ici **http://w.x.y.z:8888**. Un page avec le texte _Youpi !_ doit être affichée ; sinon il y a vraisemblablement un problème de configuration de votre serveur web.
6. Créer dans le dossier web un sous-dossier nommé _vitemadose_, au même niveau que le fichier _index.html_

### Récupération préliminaire des données (à la main)

Admettons maintenant que vous désirez tester avec des données de Caen dans le Calvados (département 14) :

1. Aller sur [le site web de production](https://vitemadose.covidtracker.fr/)
2. Ouvrir la console web du navigateur que vous utilisez
2. Saisir _14000_ et sélectionner _14000 - Caen_
3. Récupérer (via un onglet supposément nommé _Network_ par exemple) le contenu des fichiers _14.json_ qui aura les infos des centres de vaccination, ainsi que le fichier _creneaux-quotidiens.json_. S'assurer de prendre celui du bon département (URL de la forme _https://vitemadose.gitlab.io/vitemadose/14/creneaux-quotidiens.json_). Récupérer aussi le fichier _stats.json_ et le fichier _departements.json_ (par exemple via l'URL _https://vitemadose.gitlab.io/vitemadose/departements.json_)
4. Dans le sous-dossier _vitemadose_ du dossier web, mettre les fichiers _14.json_, _stats.json_ et _departements.json_
5. Dans le sous-dossier _vitemadose_ du dossier web, créér un sous-dossier _14_ et y placer le fichier _creneaux-quotidiens.json_

Maintenant, il ne reste plus qu'à compiler le projet _Xcode_ sur un appareil et lancer l'application. L'appareil doit être sur le même réseau local que la machine ayant le serveur web.

Astuce pour savoir si on affiche les données locales ou non : modifier le contenu des fichiers JSON avec des éléments exotiques comme :
- dans _stats.json_, pour l'objet **tout_departement**, remplacer la valeur du champ "disponibles" par des nombres reconnaissables
- dans le fichier _14.json_, changer le nom d'un centre de vaccination

Si toutefois, malgré tout ceci, vous pensez récupérer des données depuis le site web de production, il est possible que la configuration à distance (via _Firebase_)  ait pris la main et écrasé la configuration par défaut renseignée dans le fichier _remote-config.plist_. Auquel cas, y aller plus brutalement en remplaçant la valeur retournée par la propriété calculée `baseUrl` dans l'extension de `RemoteConfiguration` par l'adresse IP du serveur local, comme :

```swift
    var baseUrl: String {
        //return configuration.configValue(forKey: "url_base").stringValue!
        return "http://w.x.y.z:8888"
    }
```

Enfin, la recherche de créneaux Vite Ma Dose se base aussi sur les départements voisins du département concerné. Ainsi, pour le Calvados (14), les données d'autres départements sont récupérées, à savoir : l'Orne (61), la Manche (50) et l'Eure (27). Il faut donc alors faire la récupération des fichiers JSON pour ces 3 autres départements.

### Récupération préliminaire des données (via l'archive)

La chose étant un peu fastidieuse, vous pouvez vous contenter de prendre les données fournies dans une des archives du dossier _bouchons_ et les mettre dans votre dossier de serveur web.


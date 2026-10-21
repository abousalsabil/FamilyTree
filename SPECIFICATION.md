# Document de Spécifications Techniques et Fonctionnelles
## Application Communautaire d'Arbre Généalogique (شجرة العائلة)

---

## 1. Vue d'ensemble du Projet

### 1.1 Objectif
L'application **شجرة العائلة** (Arbre Généalogique Familial) a pour but d'aider les familles dispersées à construire, enrichir et préserver leur arbre généalogique de manière collaborative et sécurisée.

L'application cible principalement la langue **Arabe** avec une prise en charge native du sens de lecture **RTL (Right-To-Left)** et une extensibilité multilingue (i18n).

### 1.2 Cibles et Plateformes
- **Plateforme prioritaire (Déploiement initial)** : Application Web (Flutter Web).
- **Plateforme cible secondaire** : Application Mobile Android (Flutter Android).
- **Synchronisation** : Synchronisation en temps réel / multi-plateforme via un backend dédié.

---

## 2. Exigences Fonctionnelles

### 2.1 Gestion des Utilisateurs & Authentification
- **Inscription & Connexion** :
  - Connexion via Email / Mot de passe, Numéro de téléphone (SMS OTP) ou fournisseurs tiers (OAuth).
  - Gestion des profils utilisateurs (Nom, Prénom, Email, Photo de profil, Rôle dans la famille).
- **Rôles et Permissions** :
  - **Membre** : Peut consulter l'arbre, proposer des ajouts/modifications et participer au vote communautaire.
  - **Modérateur de branche / Famille** : Peut valider les modifications avec un poids de vote supérieur et gérer les litiges.
  - **Administrateur système** : Gestion globale des droits et de la plateforme.

### 2.2 Gestion des Membres de la Famille et Relations
- **Fiche Profil d'un Membre** :
  - Informations personnelles : Nom complet en arabe (Nom, Prénom, Nom du père, Nom du grand-père, Surnom/Laqab), Sexe, Date et lieu de naissance, Date et lieu de décès (si applicable), Biographie/Notes.
- **Gestion des Liens de Parenté** :
  - Parents (Père / Mère)
  - Enfants
  - Conjoints / Époux (prise en charge de mariages multiples)
  - Frères et sœurs (déduits automatiquement ou définis)

### 2.3 Visualisation Interactive de l'Arbre Généalogique
- **Graph Interactif** :
  - Composant de visualisation sur-mesure supportant le **Zoom/Pan** (agrandissement, déplacement fluide).
  - Support natif de l'orientation RTL (lecture de droite à gauche).
- **Vues Personnalisées** :
  - **Vue par Génération** : Affichage hiérarchique clair étagé par générations.
  - **Vue Ascendante / Descendante** : Focus sur les ancêtres ou les descendants d'une personne sélectionnée.
  - **Filtres & Recherche** : Recherche rapide par nom, branche, ville de naissance ou période.

### 2.4 Système de Vérification Communautaire & Documents Officiels
- **Vérification Communautaire** :
  - Tout ajout ou modification importante (ex: ajout d'un parent, modification de lien) génère une *demande de confirmation*.
  - **Mécanisme de vote** : Les membres de la même branche familiale reçoivent une notification et peuvent voter (Approuver / Rejeter / Commenter).
  - Seuil de validation configurable (ex: validation automatique dès 3 approbations de membres certifiés ou 1 validation de modérateur).
- **Gestion des Documents & Pièces Justificatives** :
  - Possibilité de joindre des pièces justificatives (Actes de naissance, livrets de famille, pièces d'identité, documents d'archives).
  - Statuts de vérification d'une fiche / relation :
    1. `DECLARATIF` (Non vérifié, simple déclaration)
    2. `EN_VERIFICATION` (Soumis au vote communautaire ou en revue de document)
    3. `VERIFIE` (Approuvé par la communauté ou validé par document officiel)

---

## 3. Exigences Techniques & Architecture

### 3.1 Frontend (Flutter - Web & Mobile)
- **Architecture de Code** :
  - Clean Architecture / Feature-First Architecture.
  - Gestion d'état recommandée : `flutter_bloc` ou `riverpod`.
- **Internationalisation & RTL** :
  - Utilisation du package `flutter_localizations` avec fichiers `arb` (Application Resource Bundle).
  - Configuration du `MaterialApp` avec `supportedLocales: [Locale('ar', '')]` et `locale: Locale('ar')`.
  - Emploi systématique des propriétés Directional (`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`).
- **Visualisation d'Arbre Généalogique** :
  - Intégration de bibliothèques de graphes adaptées à Flutter (ex: `graphview` ou Canvas personnalisé avec `InteractiveViewer`).

### 3.2 Backend (API REST / GraphQL sur-mesure)
- **Modèle d'API** : API RESTful ou GraphQL sur-mesure.
- **Authentification** : JWT (JSON Web Tokens) avec Refresh Tokens.
- **Stockage de Fichiers** : Stockage sécurisé des documents officiels (Object Storage / S3 compatible) avec accès restreint et chiffrement.

---

## 4. Modèle de Données (Entités Principales)

### 4.1 Entité `User`
```json
{
  "id": "UUID",
  "email": "string",
  "phone": "string",
  "role": "MEMBER | MODERATOR | ADMIN",
  "linked_member_id": "UUID (ref FamilyMember)",
  "created_at": "timestamp"
}
```

### 4.2 Entité `FamilyMember`
```json
{
  "id": "UUID",
  "first_name": "string (Arabe)",
  "father_name": "string (Arabe)",
  "grand_father_name": "string (Arabe)",
  "family_name": "string (Arabe)",
  "gender": "MALE | FEMALE",
  "birth_date": "date",
  "birth_place": "string",
  "is_alive": "boolean",
  "death_date": "date",
  "biography": "text",
  "verification_status": "DECLARATIF | EN_VERIFICATION | VERIFIE",
  "created_by": "UUID (ref User)"
}
```

### 4.3 Entité `Relationship`
```json
{
  "id": "UUID",
  "person_id": "UUID (ref FamilyMember)",
  "related_person_id": "UUID (ref FamilyMember)",
  "type": "PARENT_CHILD | SPOUSE",
  "marriage_date": "date (optional)",
  "is_active": "boolean",
  "verification_status": "DECLARATIF | EN_VERIFICATION | VERIFIE"
}
```

### 4.4 Entité `VerificationRequest` & `Vote`
```json
{
  "id": "UUID",
  "target_type": "MEMBER_CREATION | RELATIONSHIP_CREATION | PROFILE_UPDATE",
  "target_id": "UUID",
  "requester_id": "UUID (ref User)",
  "status": "PENDING | APPROVED | REJECTED",
  "approvals_count": "number",
  "rejections_count": "number",
  "created_at": "timestamp"
}
```

### 4.5 Entité `OfficialDocument`
```json
{
  "id": "UUID",
  "member_id": "UUID (ref FamilyMember)",
  "document_type": "BIRTH_CERTIFICATE | FAMILY_BOOK | OTHER",
  "file_url": "string",
  "uploaded_by": "UUID (ref User)",
  "status": "PENDING | VALIDATED | REJECTED"
}
```

---

## 5. Endpoints de l'API REST (Aperçu)

| Méthode | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/auth/register` | Inscription d'un utilisateur |
| `POST` | `/api/v1/auth/login` | Connexion utilisateur |
| `GET` | `/api/v1/family/tree` | Récupération des données du graphe de l'arbre |
| `GET` | `/api/v1/family/members/:id` | Détails d'un membre de la famille |
| `POST` | `/api/v1/family/members` | Proposition d'ajout d'un membre |
| `POST` | `/api/v1/family/relationships` | Création d'une relation entre 2 membres |
| `GET` | `/api/v1/verifications/pending` | Liste des demandes de vérification en attente |
| `POST` | `/api/v1/verifications/:id/vote` | Vote sur une demande de vérification |
| `POST` | `/api/v1/documents/upload` | Téléversement d'une pièce justificative |

---

## 6. Feuille de Route de Développement (Roadmap)

1. **Phase 1 : Cadrage & Spécifications** (Actuelle)
2. **Phase 2 : Initialisation du Projet Flutter & Config RTL/i18n**
3. **Phase 3 : Authentification & Modèle Utilisateur**
4. **Phase 4 : Graph Interactif & Visualisation de l'Arbre (Web)**
5. **Phase 5 : Gestion des Profils & Relations**
6. **Phase 6 : Système de Validation Communautaire & Documents Officiels**
7. **Phase 7 : Déploiement Web Initial & Adaptation Android**

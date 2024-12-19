from faker import Faker
from pyperclip import copy
from random import randint, choice
from datetime import datetime, timedelta
from csv import DictReader

locales = [
    "de_DE",   # Allemagne
    "it_IT",   # Italie
    "es_ES",   # Espagne
    "pt_PT",   # Portugal
    "en_GB",   # Royaume-Uni
    "fr_CH",   # Suisse (francophone)
    "en_US",   # États-Unis
    "fr_CA",   # Canada (francophone)
    "en_AU",   # Australie
    "ja_JP",   # Japon
    "zh_CN",   # Chine
    "ko_KR",   # Corée du Sud
    "ru_RU",   # Russie
]

fake = Faker('fr_FR')
mutuelles = [fake.company() for i in range(8)]
cantons = []
with open("./P2/v_canton_2024.csv", mode='r', encoding='utf-8') as file:
    lecteur_csv = DictReader(file)  # Utilisation de DictReader pour accéder aux colonnes par nom
    for ligne in lecteur_csv:
        cantons.append(ligne['BURCENTRAL'])

medicaments = []
codes_rpps = []
with open("./P2/medicaments.csv", mode='r', encoding='utf-8') as file:
    lecteur_csv = DictReader(file)  # Utilisation de DictReader pour accéder aux colonnes par nom
    for ligne in lecteur_csv:
        medicaments.append(ligne)


def generate_hour(h_start=0, h_end=23, m_start=0, m_end=59, s_start=0, s_end=59):
    return f"{randint(h_start, h_end):02}:{randint(m_start, m_end):02}:{randint(s_start, s_end):02}"


def generate_clients(n):
    '''
    Use the library faker to generate false clients
    '''
    output = "\nDELETE FROM Client WHERE ID >= 0;\n\n"
    for client in range(n):
        # Données simple à générer
        etranger = randint(0, 100) <= 10
        if etranger:
            fake = Faker(choice(locales))
        else:
            fake = Faker('fr_FR')
        mutuelle = f"'{choice(mutuelles)}'" if not etranger else "NULL"
        # On suppose qu'un étranger n'a jamais de mutuelle
        numero_adherent = randint(100000000000, 999999999999) if not etranger else "NULL"
        genre = randint(1, 2)  # 1 pour homme 2 pour femme
        nom = fake.last_name()
        prenom = fake.first_name_male() if genre == 1 else fake.first_name_female()
        date_naissance = fake.date_of_birth(minimum_age=18, maximum_age=90)

        # Numéro de sécurité sociale
        # Le numéro d'ordre permet d'avoir plusieurs personne avec les même informations
        if (not etranger) or (etranger and randint(0, 100) <= 40):
            NIR = f"{genre}{date_naissance.strftime('%y')}{date_naissance.strftime('%m')}{choice(cantons)}{randint(1, 999):03d}"
            # Remplace les cantons avec lettre en code chiffré comme prévu par l'INSEE
            NIR = NIR.replace("2A", "19")
            NIR = NIR.replace("2B", "18")
            securite_sociale = f"{NIR}{(97 - (int(NIR) % 97)):02d}"
        else:
            securite_sociale = "NULL"
        output += f"INSERT INTO Client VALUES ({client},'{nom}','{prenom}',TO_DATE('{date_naissance.strftime('%Y/%m/%d')}', 'YYYY/MM/DD'),{securite_sociale},{mutuelle},{numero_adherent});\n"
    return output


def generate_doctor(n):
    '''
    Use the library faker to generate false doctors
    '''
    global codes_rpps
    fake = Faker("fr_FR")
    output = "\nDELETE FROM Medecin WHERE RPPS >= 0;\n\n"
    for _ in range(n):
        genre = randint(1, 2)  # 1 pour homme 2 pour femme
        nom = fake.last_name()
        prenom = fake.first_name_male() if genre == 1 else fake.first_name_female()
        address = address = fake.address().replace("\n", " ")
        rpps = randint(10000000000, 99999999999)
        while rpps in codes_rpps:
            rpps = randint(10000000000, 99999999999)
        output += f"INSERT INTO Medecin VALUES ({rpps},'{nom}','{prenom}','{address}');\n"
        codes_rpps.append(rpps)
    return output


def generate_medicaments():
    '''
    Read a csv and convert it's data into SQL commands. The csv comes from ChatGPT.
    '''
    output = "\nDELETE FROM Medicament WHERE CIP >= 0;\n\n"
    for med in medicaments:
        output += f"INSERT INTO Medicament VALUES ('{med['CIP']}','{med['Nom_Commercial']}',{med['Taux_remboursement']},{med['Prix']},{10},{med['Posologie']},'{med['Requiert_ord']}');\n"
    return output


def generate_commandes(delivered: int, non_delivered: int, expired: int):
    output = "\nDELETE FROM Comm_med WHERE ID_COMMANDE >= 0;\nDELETE FROM Commande WHERE ID >= 0;\n-- Commandes expirées\n"
    ID = 0

    for _ in range(expired):    # On rajoute des commandes expirées
        today = datetime.today()

        date_commande = fake.date_between(start_date=today - timedelta(days=180), end_date=today - timedelta(days=16))
        date_livraison = date_commande + timedelta(days=randint(7, 14))
        date_expiration = (date_livraison + timedelta(days=15)).strftime('%Y/%m/%d') + ' ' + generate_hour(0, 0, 0, 0, 0, 0)

        date_livraison = f"TO_TIMESTAMP('{date_livraison.strftime('%Y/%m/%d') + ' ' + generate_hour()}', 'YYYY/MM/DD HH24:MI:SS')"
        date_expiration = f"TO_TIMESTAMP('{date_expiration}', 'YYYY/MM/DD HH24:MI:SS')"
        date_commande = f"TO_TIMESTAMP('{date_commande.strftime('%Y/%m/%d')}', 'YYYY/MM/DD HH24:MI:SS')"

        # Insérer les valeurs dans le format SQL
        output += f"INSERT INTO Commande (ID, Date_commande, Date_livraison, Date_expiration) VALUES ({ID}, {date_commande}, {date_livraison}, {date_expiration});\n"
        ID += 1

    output += "-- Commandes faites mais non livrées\n"
    for _ in range(non_delivered):  # On rajoute des commandes qui ont été faites mais pas encore livrées
        today = datetime.today()
        date_commande = fake.date_between(start_date=today - timedelta(days=32), end_date=today)
        date_commande = f"TO_TIMESTAMP('{date_commande.strftime('%Y/%m/%d')}', 'YYYY/MM/DD HH24:MI:SS')"
        output += f"INSERT INTO Commande (ID, Date_commande, Date_livraison, Date_expiration) VALUES ({ID}, {date_commande}, NULL, NULL);\n"
        ID += 1

    output += "-- Commandes faites et livrées\n"
    for _ in range(delivered):   # On rajoute des commandes qui ont été faites et livrées
        today = datetime.today()

        date_commande = fake.date_between(start_date=today - timedelta(days=180), end_date=today - timedelta(days=16))
        date_livraison = date_commande + timedelta(days=randint(7, 14))
        date_livraison = f"TO_TIMESTAMP('{date_livraison.strftime('%Y/%m/%d') + ' ' + generate_hour()}', 'YYYY/MM/DD HH24:MI:SS')"
        date_commande = f"TO_TIMESTAMP('{date_commande.strftime('%Y/%m/%d')}', 'YYYY/MM/DD HH24:MI:SS')"
        output += f"INSERT INTO Commande (ID, Date_commande, Date_livraison, Date_expiration) VALUES ({ID}, {date_commande}, {date_livraison}, NULL);\n"
        ID += 1

    return output


def generate_ordonnance(n):
    '''
    Generate lists of drugs. Those prescriptions are unrealistic as they do not take into account laws and needed quantities.
    '''
    today = datetime.today()
    output = "\nDELETE FROM Ordonnance WHERE ID_ORDO >= 0;\n\n"
    for client_id in range(n):
        medicaments_ord = set(tuple(med.values()) for med in medicaments)
        med_choisis = set()
        docteur = choice(codes_rpps)
        date = f"TO_DATE('{fake.date_between(start_date=today - timedelta(days=14), end_date=today).strftime('%Y/%m/%d')}', 'YYYY/MM/DD HH24:MI:SS')"
        for _ in range(randint(1, 5)):  # Une ordonnance/achat contient entre 1 et 5 médicaments
            medicament = choice(list(medicaments_ord - med_choisis))
            output += f"INSERT INTO Ordonnance (Id_Client, Nom_commercial, RPPS, Posologie, dDate) VALUES ({client_id},'{medicament[1]}',{docteur if medicament[5] == 'True' else 'NULL'},{float(medicament[4]) * randint(2, 5):.2f},{date if medicament[5] == 'True' else 'SYSDATE'});\n"
            med_choisis.add(medicament)
    return output


n_uplets = 30
dataset = generate_clients(n_uplets) + generate_doctor(n_uplets) + generate_medicaments() + generate_commandes(3, 3, 3) + generate_ordonnance(n_uplets // 2)
print(dataset)
if len(dataset) >= 30000:
    print("Attention, SQL LIVE ne permet pas de gérer autant de commandes !")
copy(dataset)

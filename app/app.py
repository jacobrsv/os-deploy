###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################


from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
import datetime, uuid, random
from faker import Faker
import plotly.express as px

# Bruger Faker til testdata
fake = Faker()

# Initialiserer flask og database
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
db = SQLAlchemy(app)

def prettylog(*args):
    bold_underline_cyan = "\033[96m\033[1m\033[4m"
    clear_formatting = "\033[0m"
    str_to_print = " ".join(str(arg) for arg in args)
    print(bold_underline_cyan + str_to_print + clear_formatting)


# ComputerInfo klassen
class ComputerInfo(db.Model):
    serial_number = db.Column(db.String(100), primary_key=True)
    uuid = db.Column(db.String(36), nullable=False)
    computer_name = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, default=datetime.datetime.now)
    ip_address = db.Column(db.String(15), nullable=False)
    mac_address = db.Column(db.String(17), nullable=False)
    win_build = db.Column(db.String(10), nullable=False)
    win_ver = db.Column(db.String(12), nullable=False)
    win_name = db.Column(db.String(100), nullable=False)


# Initialiserer database, opretter data.db og tabeller hvis de ikke eksisterer.
with app.app_context():
    db.create_all()


##### Index ###################################################################
@app.route('/', methods=['GET', 'POST'])
def index():
    # Håndter POST, til at slette et ComputerInfo objekt
    if request.method == 'POST':
        serial_number = request.form['serial_number']
        print(serial_number)
        record_to_delete = ComputerInfo.query.filter_by(serial_number=serial_number).first()
        db.session.delete(record_to_delete)
        db.session.commit()

    # Get all records from the database
    computer_info = ComputerInfo.query.order_by(ComputerInfo.date.desc()).all()
    number_of_records = len(computer_info)
    prettylog("Number fo records in db: ", number_of_records)
    
    # Tæl forskellige Windows-versioner
    win_ver_counts = db.session.query(
        ComputerInfo.win_ver,
        db.func.count(ComputerInfo.win_ver) # Får SQL til at tælle
        ).group_by(ComputerInfo.win_ver).all()
    # Opstil data til diagrammet
    #   [( Version, Count ), ( Version, Count )]   f.eks.:
    #   [('10.0.19044', 25), ('10.0.26100', 22)]
    data = {
        "Windows Version": [item[0] for item in win_ver_counts],
        "Count": [item[1] for item in win_ver_counts]
    }

    # Cirkeldiagram med Plotly Express
    pie_fig = px.pie(data,
                     names="Windows Version",
                     values="Count",
                     title="Windows Version Distribution",
                     height=410,
                     width=640,
                     )
    pie_fig.update_layout(
        plot_bgcolor="#f9f9f9",
        paper_bgcolor="#f9f9f9"
    )
    pie_fig = pie_fig.to_html()
    
    return render_template('index.html',
                           computer_info=computer_info,
                           number_of_records=number_of_records,
                           piechart=pie_fig)


##### Tilføj computer #########################################################
@app.route('/add', methods=['GET', 'POST'])
def add_info():
    if request.method == 'POST':
        # Hent data fra HTML form
        uuid = request.form['uuid']
        serial_number = request.form['serial_number']
        computer_name = request.form['computer_name']
        ip_address = request.form['ip_address']
        mac_address = request.form['mac_address']
        win_name = request.form['win_name']
        win_ver = request.form['win_ver']
        win_build = request.form['win_build']

        # Se om der allerede findes en record i databasen
        existing_computer = ComputerInfo.query.filter_by(
            serial_number=serial_number).first()
        if existing_computer:           # findes
            # Opdaterer eksisterende ComputerInfo objekt
            prettylog("Updating existing record:")
            prettylog("  Name:    ", existing_computer.computer_name)
            prettylog("  IP:      ", existing_computer.ip_address)
            prettylog("  Version: ", existing_computer.win_name)
            print()
            existing_computer.date = datetime.datetime.now()
            existing_computer.uuid = uuid
            existing_computer.computer_name = computer_name
            existing_computer.ip_address = ip_address
            existing_computer.mac_address = mac_address
            existing_computer.win_name = win_name
            existing_computer.win_ver = win_ver
            existing_computer.win_build = win_build
        else:                           # findes ikke
            # Opretter nyt ComputerInfo objekt
            new_computer = ComputerInfo(uuid=uuid,
                                        serial_number=serial_number,
                                        computer_name=computer_name,
                                        ip_address=ip_address,
                                        mac_address=mac_address,
                                        win_name=win_name,
                                        win_build=win_build,
                                        win_ver=win_ver)
            prettylog("Creating new record:")
            prettylog("  Name:    ", new_computer.computer_name)
            prettylog("  IP:      ", new_computer.ip_address)
            prettylog("  Version: ", new_computer.win_name)
            print()
            
            db.session.add(new_computer)
        db.session.commit()

        return redirect(url_for('index'))

    return render_template('add.html')

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()

##### Configuration ###########################################################
@app.route('/config')
def config():
    # Læser filer, putter dem i en liste og sender dem videre.
    scripts = [read_file('../scripts/start.sh'),
               read_file('../scripts/format.sh'),
               read_file('../scripts/download.sh'),
               read_file('../scripts/firstrun.ps1')]

    return render_template('config.html', scripts=scripts)


##### Generer testdata ########################################################
@app.route('/addtestdata/<int:amount>')
def add_test_data(amount):
    windows_strings = ['Microsoft Windows 11 Education N',
                       'Microsoft Windows 10 Pro']
    windows_versions = ['10.0.19044','10.0.26100']
    windows_builds = ['19044','26100']

    for _ in range(amount):
        # Generer værdier
        fake_uuid = str(uuid.uuid4()).upper()
        fake_serial_number = f"SN{random.randint(10000, 99999)}"
        fake_computer_name = f"CONTOSO-{fake_serial_number}"
        fake_ip_address = fake.ipv4(private=True)
        fake_mac_address = fake.mac_address().replace(':','-').upper()
        fake_win_name = random.choice(windows_strings)
        fake_win_ver = random.choice(windows_versions)
        fake_win_build = random.choice(windows_builds)
        # Put værdier i ComputerInfo objekt
        fake_computer = ComputerInfo(uuid=fake_uuid,
                            serial_number=fake_serial_number,
                            computer_name=fake_computer_name,
                            ip_address=fake_ip_address,
                            mac_address=fake_mac_address,
                            win_name=fake_win_name,
                            win_build=fake_win_build,
                            win_ver=fake_win_ver)
        try:
            db.session.commit()
            db.session.add(fake_computer)
        except IntegrityError as e:
        # Nogle gange finder den på det samme serienummer,
        # Det resulterer i en UNIQUE Constraint. Det ignorerer vi.
            print(repr(e))
            db.session.rollback()
            continue
    return 'ok'


##### Browse os images ########################################################
@app.route('/browse')
def browse():
    return render_template('browse.html')


# Kør appen i et unix socket, som Caddy samler op.
if __name__ == '__main__':
    app.run(debug=True, host="unix://../app.sock")


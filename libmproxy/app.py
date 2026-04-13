import flask
import OpenSSL.crypto

mapp = flask.Flask(__name__)
mapp.debug = True


@mapp.route("/")
def index():
    return flask.render_template("index.html", section="home")


def _cacert_path():
    return flask.current_app.config["PMASTER"].server.config.cacert


@mapp.route("/certs")
def certs():
    cacert = _cacert_path()
    cert_info = None
    if cacert:
        try:
            with open(cacert, "rb") as f:
                pem_data = f.read()
            x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, pem_data)
            cert_info = {
                "cn": x509.get_subject().CN,
                "not_before": x509.get_notBefore().decode(),
                "not_after": x509.get_notAfter().decode(),
                "serial": x509.get_serial_number(),
                "sha256": x509.digest("sha256").decode(),
            }
        except Exception as e:
            cert_info = {"error": str(e)}
    return flask.render_template("certs.html", section="certs", cert_info=cert_info)


@mapp.route("/cert/pem")
def cert_pem():
    cacert = _cacert_path()
    if not cacert:
        flask.abort(404)
    with open(cacert, "rb") as f:
        data = f.read()
    return flask.Response(
        data,
        mimetype="application/x-x509-ca-cert",
        headers={"Content-Disposition": "attachment; filename=mitmproxy-ca-cert.pem"},
    )


@mapp.route("/cert/der")
def cert_der():
    cacert = _cacert_path()
    if not cacert:
        flask.abort(404)
    with open(cacert, "rb") as f:
        pem_data = f.read()
    x509 = OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, pem_data)
    der_data = OpenSSL.crypto.dump_certificate(OpenSSL.crypto.FILETYPE_ASN1, x509)
    return flask.Response(
        der_data,
        mimetype="application/x-x509-ca-cert",
        headers={"Content-Disposition": "attachment; filename=mitmproxy-ca-cert.cer"},
    )

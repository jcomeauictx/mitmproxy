from libmproxy import encoding

def test_identity():
    assert "string" == encoding.decode("identity", "string")
    assert "string" == encoding.encode("identity", b'string')
    assert not encoding.encode("nonexistent", b'string')
    assert None == encoding.decode("nonexistent encoding", "string")


def test_gzip():
    assert "string" == encoding.decode("gzip", encoding.encode("gzip", b'string'))
    assert None == encoding.decode("gzip", "bogus")


def test_deflate():
    assert "string" == encoding.decode("deflate", encoding.encode("deflate", b'string'))
    assert "string" == encoding.decode("deflate", encoding.encode("deflate", b'string')[2:-4])
    assert None == encoding.decode("deflate", "bogus")


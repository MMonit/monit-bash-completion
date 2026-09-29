import pytest


@pytest.mark.bashcomp(pre_cmds=("PATH=$PWD/monit/bin:$PATH",))
class TestMonit:
    @pytest.mark.complete("monit ")
    def test_commands(self, completion):
        assert completion == "procmatch report start status stop".split()

    @pytest.mark.complete("monit -")
    def test_options(self, completion):
        assert "--conf" in completion
        assert "--group" in completion

    @pytest.mark.complete("monit -v --conf /dev/null st")
    def test_commands_after_options(self, completion):
        assert completion == "start status stop".split()

    @pytest.mark.complete("monit start ")
    def test_start(self, completion):
        assert completion == "all gateway hosts localhost nginx".split()

    @pytest.mark.complete("monit status ")
    def test_status(self, completion):
        assert completion == "gateway hosts localhost nginx".split()

    @pytest.mark.complete("monit status nginx ")
    def test_single_service_only(self, completion):
        assert not completion

    @pytest.mark.complete("monit -c /dev/null status ")
    def test_conffile(self, completion):
        assert completion == "backup localhost".split()

    @pytest.mark.complete("monit --conf=/dev/null status ")
    def test_conffile_long_equals(self, completion):
        assert completion == "backup localhost".split()

    @pytest.mark.complete("monit -vc/dev/null status ")
    def test_conffile_short_bundled(self, completion):
        assert completion == "backup localhost".split()

    @pytest.mark.complete("monit -g ")
    def test_groups(self, completion):
        assert completion == "files web www".split()

    @pytest.mark.complete("monit -c /dev/null --group ")
    def test_groups_conffile(self, completion):
        assert completion == "jobs"

    @pytest.mark.complete("monit report ")
    def test_report(self, completion):
        assert completion == "down initialising total unmonitored up".split()

    @pytest.mark.complete("monit -c shared/default/")
    def test_conffile_filedir(self, completion):
        assert "foo.d/" in completion

    @pytest.mark.complete("monit -l sys")
    def test_logfile_syslog(self, completion):
        assert completion == "log"

    @pytest.mark.complete("monit -d ")
    def test_daemon(self, completion):
        assert not completion

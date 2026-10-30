import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
module=importlib.util.spec_from_file_location("prepare_setup",ROOT/"scripts/prepare_setup.py")
setup=importlib.util.module_from_spec(module);module.loader.exec_module(setup)
class SetupIntakeTests(unittest.TestCase):
    def setUp(self):
        self.spec=setup.load_spec()
        a={f["key"]:(None if f["type"]=="number" else f["default"]) for f in self.spec["fields"]}
        a.update(company_name="Example Agency",project_name="Example People",contact_name="Setup Owner",contact_email="owner@example.test",account_owner_email="owner@example.test",time_zone="UTC",acknowledge=True,app_url="https://portal.example.test",r2_account_id="syntheticaccount",r2_bucket="private-test")
        self.data={"schema_version":1,"submitted_at":"2026-10-30T12:00:00Z","answers":a}
    def test_choices_become_config_with_secrets_placeholder_and_features_off(self):
        self.assertEqual(setup.validate(self.data,self.spec),[])
        with tempfile.TemporaryDirectory() as base:
            output=Path(base)/"prepared";plan=setup.prepare(self.data,self.spec,output)
            self.assertFalse(plan["live_verified"]);self.assertEqual(plan["network_calls"],0)
            self.assertEqual(plan["brand"]["companyName"],"Example Agency")
            self.assertTrue(all(x is False for x in plan["feature_flags"].values()))
            env=(output/".env.setup.example").read_text()
            self.assertIn('APP_URL="https://portal.example.test"',env)
            self.assertIn('AUTH_SECRET="REPLACE_LOCALLY"',env)
            self.assertEqual(len(list(output.iterdir())),3)
            with self.assertRaises(ValueError):setup.prepare(self.data,self.spec,output)
    def test_missing_required_and_unknown_keys_rejected(self):
        d=copy.deepcopy(self.data);d["answers"]["contact_email"]="";d["answers"]["shell_command"]="do not execute"
        self.assertTrue(setup.validate(d,self.spec))
    def test_credential_patterns_and_credential_urls_rejected(self):
        d=copy.deepcopy(self.data);d["answers"]["notes"]="ghp_"+"x"*30
        self.assertTrue(setup.validate(d,self.spec))
        d=copy.deepcopy(self.data);d["answers"]["app_url"]="https://user:password@example.test"
        self.assertTrue(setup.validate(d,self.spec))
    def test_invalid_choice_timezone_and_negative_budget_rejected(self):
        for key,value in [("environment","production"),("time_zone","Invalid/NotAZone"),("monthly_budget_usd",-1)]:
            d=copy.deepcopy(self.data);d["answers"][key]=value
            self.assertTrue(setup.validate(d,self.spec))
if __name__=="__main__":unittest.main()

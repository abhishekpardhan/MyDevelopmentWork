"""NOT EXECUTED. Archived official agentforce-sdk reference example.

Default plan performs no imports of third-party code and no network operations.
No SDK-native dry-run is assumed. This is a lab-owned execution gate.
"""
import argparse
import contextlib
import io
import logging
import os


def build_model():
    from agent_sdk.models import Agent, Topic, SystemMessage

    agent = Agent(name="Lab03_SDK_Demo", description="Fictional logistics learning only",
                  agent_type="Internal", company_name="Fictional Training Company")
    topic = Topic(name="Training", description="Generic logistics concepts",
                  scope="Fictional examples only; no company facts or operations")
    topic.instructions = ["Use fictional examples only. Never quote real rates or promise delivery."]
    agent.topics = [topic]
    agent.system_messages = [SystemMessage(message="Provide generic training guidance only.", msg_type="system")]
    return agent


def make_client():
    from agent_sdk import Agentforce
    # SDK authentication differs from the Agent API client-credentials workflow.
    return Agentforce(session_id=os.environ["SF_SDK_SESSION_ID"],
                      instance_url=os.environ["SF_MY_DOMAIN"])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["plan", "model", "retrieve", "metadata", "create"], default="plan")
    parser.add_argument("--approved", action="store_true")
    args = parser.parse_args()
    if args.mode == "plan":
        print("NOT EXECUTED: model -> optional retrieve/configuration -> explicit approval -> create/deploy -> inspect deployResult.status.")
        return
    if not args.approved:
        raise SystemExit("BLOCKED: dependency review and operation approval required.")
    # Suppress third-party stdout/logging: never dump configuration, tokens, or errors.
    logging.disable(logging.CRITICAL)
    try:
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            if args.mode == "model":
                build_model()  # Local model construction; NOT an org dry-run.
            elif args.mode == "retrieve":
                make_client().retrieve(os.environ["SF_SDK_AGENT_ID"])
            elif args.mode == "metadata":
                make_client().retrieve_metadata("Bot", agent_name=os.environ["SF_SDK_AGENT_NAME"])
            else:
                if os.environ.get("SF_SDK_MUTATION_APPROVAL") != "CREATE_LAB03_SDK_DEMO_AFTER_COLLISION_REVIEW":
                    raise RuntimeError("Missing explicit scoped approval")
                # NOT an AiAuthoringBundle workflow. Review SDK/version and collision first.
                result = make_client().create(build_model())
                if not result or result.get("deployResult", {}).get("status") != "Succeeded":
                    raise RuntimeError("Deployment not confirmed")
        print("Operation returned successfully; no raw metadata or credentials displayed.")
    except Exception:
        raise SystemExit("BLOCKED/FAIL: SDK operation unavailable or unsuccessful; raw error suppressed.") from None


if __name__ == "__main__":
    main()

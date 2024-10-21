from crewai import Agent, Crew, Process, Task, LLM
from crewai.project import CrewBase, agent, crew, task

from crewai_tools import SerperDevTool, GithubSearchTool
from starlette.config import environ


@CrewBase
class OffensiveSolidityAgentsCrew:
	"""OffensiveSolidityAgents crew"""

	def __init__(self):
		self.codellama_llm = LLM(model="ollama/llama3:8b", base_url="http://localhost:11434")
		self.gpt4_llm = LLM(model="gpt-4", temperature=0.7)
		self.defi_hacklabs_github_tool = GithubSearchTool(
			gh_token=environ.get("GITHUB_TOKEN"),
			github_repo='https://github.com/SunWeb3Sec/DeFiHackLabs',
			content_types=['code', 'repo'] # Options: code, repo, pr, issue
		)


	def _create_agent(self, agent_name: str, llm, allowed_tools=[]) -> Agent:
		"""Creates an agent from the crew"""
		print(f"Creating agent {agent_name}")
		return Agent(
			config=self.agents_config[agent_name],
			verbose=True,
			llm=llm, # ChatOpenAI(temperature=0, model='gpt-4')
			tools=allowed_tools,
			allow_delegation=True
		)

	"""
	@agent
	def researcher(self) -> Agent:
		return Agent(
			config=self.agents_config['researcher'],
			# tools=[MyCustomTool()], # Example of custom tool, loaded on the beginning of file
			verbose=True
		)

	@agent
	def reporting_analyst(self) -> Agent:
		return Agent(
			config=self.agents_config['reporting_analyst'],
			verbose=True
		)
	"""

	def manager(self) -> Agent:
		return self._create_agent('manager', self.gpt4_llm)

	@agent
	def smart_contract_researcher(self) -> Agent:
		return self._create_agent(
			'smart_contract_researcher',
			self.gpt4_llm,
			[
				SerperDevTool(),
				self.defi_hacklabs_github_tool
			]
		)

	@agent
	def static_code_analysis_agent(self) -> Agent:
		return self._create_agent('static_code_analysis_agent', self.gpt4_llm)

	@agent
	def detector_agent(self) -> Agent:
		return self._create_agent(
			'detector_agent',
			self.gpt4_llm,
			[self.defi_hacklabs_github_tool]
		)

	@agent
	def smart_contract_auditor(self) -> Agent:
		return self._create_agent(
			'smart_contract_auditor',
			self.gpt4_llm,
			[self.defi_hacklabs_github_tool]
		)

	@agent
	def smart_contract_audit_decider(self) -> Agent:
		return self._create_agent(
			'smart_contract_audit_decider',
			self.gpt4_llm,
			[self.defi_hacklabs_github_tool]
		)

	@agent
	def tests_writer(self) -> Agent:
		return self._create_agent(
			'tests_writer',
			self.codellama_llm,
			[self.defi_hacklabs_github_tool, SerperDevTool()]
		)

	"""
	@agent
	def documenting_agent(self) -> Agent:
		return self._create_agent('documenting_agent')


	@task
	def research_task(self) -> Task:
		return Task(
			config=self.tasks_config['research_task'],
		)

	@task
	def reporting_task(self) -> Task:
		return Task(
			config=self.tasks_config['reporting_task'],
			output_file='report.md'
		)
	"""

	@task
	def smart_contract_research_task(self) -> Task:
		return Task(
			config=self.tasks_config['smart_contract_research_task'],
		)

	@task
	def defi_hacklabs_research_task(self) -> Task:
		return Task(
			config=self.tasks_config['defi_hacklabs_research_task'],
		)

	@task
	def static_code_analysis_task(self) -> Task:
		return Task(
			config=self.tasks_config['static_code_analysis_task'],
			context=[self.smart_contract_research_task(), self.defi_hacklabs_research_task()]
		)

	@task
	def detection_task(self) -> Task:
		return Task(
			config=self.tasks_config['detection_task'],
			context=[self.smart_contract_research_task(), self.defi_hacklabs_research_task()]
		)

	@task
	def smart_contract_audit_task(self) -> Task:
		return Task(
			config=self.tasks_config['smart_contract_audit_task'],
			context=[self.smart_contract_research_task(), self.defi_hacklabs_research_task(),
					 self.detection_task()]
		)

	@task
	def smart_contract_audit_decision_task(self) -> Task:
		return Task(
			config=self.tasks_config['smart_contract_audit_decision_task'],
			context=[self.smart_contract_audit_task()]
		)

	@task
	def tests_writer_task(self) -> Task:
		return Task(
			config=self.tasks_config['tests_writer_task'],
			context=[self.smart_contract_research_task(), self.defi_hacklabs_research_task(),
					 self.smart_contract_audit_decision_task()]
		)

	"""
	@task
	def documentation_task(self) -> Task:
		return Task(
			config=self.tasks_config['documentation_task'],
		)
	"""

	@crew
	def crew(self) -> Crew:
		"""Creates the OffensiveSolidityAgents crew"""
		return Crew(
			agents=self.agents, # Automatically created by the @agent decorator
			tasks=self.tasks, # Automatically created by the @task decorator
			# process=Process.sequential,
			verbose=True,
			process=Process.hierarchical, # In case you wanna use that instead https://docs.crewai.com/how-to/Hierarchical/
			# manager_llm=ChatOpenAI(temperature=0, model='gpt-4'),
			manager_agent=self.manager(),
			respect_context_window=True,
			planning=True,
			memory=True,
			output_log_file='output.log',
		)
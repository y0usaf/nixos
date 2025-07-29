# Claude Code NixOS Agents

This directory contains specialized agent profiles for NixOS configuration management work.

## Available Agents

### 🏗️ [NixOS Architecture Agent](./nixos-architecture-agent.md)
**Purpose**: Module structure analysis and consolidation planning  
**When to use**: Architecture reviews, consolidation planning, dependency analysis  
**Trigger phrases**: "analyze architecture", "plan consolidation", "assess module structure"

### 🔍 [NixOS Verification Agent](./nixos-verification-agent.md)  
**Purpose**: System integrity verification and zero-change validation  
**When to use**: After any configuration changes, build verification, regression testing  
**Trigger phrases**: "verify system", "check integrity", "validate changes"

### 🧹 [NixOS Cleanup Agent](./nixos-cleanup-agent.md)
**Purpose**: Dead code elimination and post-consolidation cleanup  
**When to use**: After consolidations, removing unused files, optimizing imports  
**Trigger phrases**: "cleanup dead code", "remove redundant files", "eliminate waste"

### 🎓 [NixOS Expert Agent](./nixos-expert-agent.md)
**Purpose**: Deep Nix expertise and complex problem solving  
**When to use**: Complex issues, advanced optimizations, best practices guidance  
**Trigger phrases**: "nix expertise needed", "complex nix problem", "best practices"

## Usage Patterns

### 1. **Sequential Agent Workflow**
```
Architecture Agent → plan changes
Verification Agent → verify current state  
[Make changes]
Verification Agent → verify changes worked
Cleanup Agent → clean up artifacts
```

### 2. **Expert Consultation**
```
Expert Agent → analyze complex problem
Architecture Agent → plan implementation  
Verification Agent → validate approach
```

### 3. **Automated Agent Triggers**
- Use verification agent after every configuration change
- Use cleanup agent after any consolidation operation
- Use architecture agent before major refactoring
- Use expert agent for unfamiliar patterns or complex debugging

## Agent Invocation Template

```markdown
Task(
  subagent_type="general-purpose",
  description="[Agent Type] [Task Description]", 
  prompt="Acting as a [Agent Name]: [Specific task with context and requirements]"
)
```

## Project History

This agent system was developed during a massive NixOS consolidation project:
- **Original**: 179 files across modular structure  
- **Consolidated**: 503+ lines in single default.nix
- **Achievement**: 37+ modules consolidated, 28+ files eliminated
- **Verification**: Zero package changes maintained throughout

The agents were designed based on the real challenges and patterns encountered during this consolidation work.

## Future Enhancements

- **Agent Memory**: Persistent context across invocations
- **Agent Coordination**: Automatic agent-to-agent handoffs  
- **Specialized Tools**: Custom tools for each agent type
- **Trigger Automation**: Automatic agent invocation based on file changes
- **Performance Metrics**: Quantified agent effectiveness measurement
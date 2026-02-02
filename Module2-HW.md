# Module2 Home Work - Kestra Workflow Orchestration

## Question 1: What is the uncompressed file size (i.e. the output file yellow_tripdata_2020-12.csv of the extract task)?

### To output the uncompressed file size, additional tasks were added to the flow to output and log the file size.

'''YAML
- id: get_file_size
    type: io.kestra.plugin.core.storage.Size
    uri: "{{render(vars.data)}}"

  id: log_file_size
    type: io.kestra.plugin.scripts.shell.Commands
    commands:
      - echo "file size for {{ inputs.taxi }} taxi data ({{ inputs.year }}-{{ inputs.month }}):{{ outputs.get_file_size.size }} bytes"
  '''

  









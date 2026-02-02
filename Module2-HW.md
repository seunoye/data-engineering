# Module2 Home Work - Kestra Workflow Orchestration

## Question 1: What is the uncompressed file size (i.e. the output file yellow_tripdata_2020-12.csv of the extract task)?

To output the uncompressed file size, additional tasks were added to the flow to log the file size.

'''yaml

    - id: get_file_size
    type: io.kestra.plugin.core.storage.Size
    uri: "{{render(vars.data)}}"

    -id: log_file_size
    type: io.kestra.plugin.scripts.shell.Commands
    commands:
    - echo "file size for {{ inputs.taxi }} taxi data ({{ inputs.year }}-{{ inputs.month }}):{{ outputs.get_file_size.size }} bytes"
  '''

### Flow execution 
<img width="927" height="607" alt="image" src="https://github.com/user-attachments/assets/daa4301d-28f2-4d32-8486-287d15fa68e1" />

### Output file size after execution
<img width="1482" height="916" alt="image" src="https://github.com/user-attachments/assets/ddfada3f-2647-4441-b54a-65c8424c7368" />
134.5 MiB


  

  









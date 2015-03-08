package layer;

`include "uvm_macros.svh"
    import uvm_pkg::*;

    typedef enum {READ, WRITE} rw_t;

class policy_base#(type ITEM=uvm_object);
    ITEM item;

    virtual      function void set_item(ITEM item);
        this.item = item;
    endfunction
    
endclass

class addr_txn;
    rand bit [31:0] addr;
    rand int size;
    rand policy_base#(addr_txn) policy[$];

    constraint c_size { size inside {1,2,4}; }

    function void pre_randomize;
        foreach(policy[i]) policy[i].set_item(this);
    endfunction

endclass
    
class rw_txn extends addr_txn;
    rand rw_t op;

    function void rprint();
        this.randomize();
        this.print();        
    endfunction

    function void print();
        $display("  addr=%h size=%0d", this.addr, this.size);
    endfunction
    
endclass
    
class policy_list#(type ITEM=uvm_object) extends policy_base #(ITEM);
    rand policy_base#(ITEM) policy[$];

    function void add(policy_base#(ITEM) pcy);
        policy.push_back(pcy);
    endfunction

    function void set_item(ITEM item);
        foreach(policy[i]) policy[i].set_item(item);
    endfunction
    
endclass
    
class addr_permit extends policy_base#(addr_txn);
    constraint c_addr_permit {
        // Transaction addr range must fit within certain ranges
        item.addr inside {['h00000000 : 'h0000FFFF - item.size]} ||
        item.addr inside {['h10000000 : 'h1FFFFFFF - item.size]};        
    }
endclass

class addr_prohibit extends policy_base#(addr_txn);
    constraint c_addr_prohibit {
        // Transaction addr range must fit within certain ranges
        // transaction must avoid "magic" testbench control addresses
        !(item.addr inside {['h00000000 : 'h00000FFF - item.size]});
    }
endclass
    
class rw_constrained_txn extends rw_txn;
    function new;
        addr_permit permit = new;
        addr_prohibit prohibit = new;
        policy_list#(addr_txn) pcy = new;

        pcy.add(permit);
        pcy.add(prohibit);
        policy = {pcy};
    endfunction
endclass
    

    
endpackage    

module TB ();

    import layer::*;
    layer::rw_constrained_txn rw_constrained_txn;
    
    initial begin
        rw_constrained_txn = new;
        
        $display("\nFIGURE 8. Bundling multiple policies into a policy_list object:");
        for (int i = 0; i < 5; i++) begin
            rw_constrained_txn.rprint();
        end
        
    end
   
endmodule
